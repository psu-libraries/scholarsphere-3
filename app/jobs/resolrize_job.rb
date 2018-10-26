# frozen_string_literal: true

class ResolrizeJob < ActiveJob::Base
  queue_as :resolrize

  def perform
    # set the timeout on the faraday connection to something huge so we can get access to the entire graph even if Fedora is being slow
    connection = Faraday.new(ActiveFedora.fedora.host + ActiveFedora.fedora.base_path, request: { timeout: 800 })
    connection.basic_auth(ActiveFedora.fedora_config.credentials['user'], ActiveFedora.fedora_config.credentials['password'])
    ldp_client = Ldp::Client.new(connection)
    resource = Ldp::Resource::RdfSource.new(ldp_client, ActiveFedora.fedora.host + ActiveFedora.fedora.base_path)

    # GET could be slow if it's a big resource, we're using HEAD to avoid this problem,
    # but this causes more requests to Fedora.
    return [] unless resource.head.rdf_source?

    descendant_uris = resource.graph.query(predicate: ::RDF::Vocab::LDP.contains).map { |descendant| descendant.object.to_s }

    # map uri to id to make filtering types easier
    descendant_ids = descendant_uris.map { |uri| ActiveFedora::Base.uri_to_id(uri) }.compact

    # models have the 10 digit ids fron AF Noid so remove the longer ones
    model_ids = descendant_ids.reject { |id| id.length > model_id_length }
    model_ids = model_ids.sort { |a, b| [b.size, b] <=> [a.size, a] }

    # permissions have the longer ids
    permission_ids = descendant_ids.reject { |id| id.length <= model_id_length }

    # run the permission ids first so that solr has the permissions before the index is updated for the model
    update_group(permission_ids)
    puts permission_ids

    # run update index on the permissions of the models and the model
    update_permissions(model_ids)

    # run the models a second time to make sure any relationships between the models get assigned correctly
    update_group(model_ids)
  end

  private

    def model_id_length
      10
    end

    def update_group(ids)
      ids.each do |id|
        logger.debug "Re-index everything ... #{id}"
        begin
          ActiveFedora::Base.find(id).update_index
        rescue StandardError => error
          logger.error "error processing #{id}: #{error}"
        end
      end
    end

    def update_permissions(ids)
      ids.each do |id|
        logger.debug "Re-index everything permissions ... #{id}"
        begin
          model = ActiveFedora::Base.find(id)
          model.permissions.each do |perm|
            puts perm.id
            ActiveFedora::Base.find(perm.id).update_index
          end
          model.update_index
        rescue StandardError => error
          logger.error "error processing #{id}: #{error}"
        end
      end
    end
end
