# frozen_string_literal: true
class ResolrizeJob < ActiveJob::Base
  queue_as :resolrize

  def perform
    resource = Ldp::Resource::RdfSource.new(ActiveFedora.fedora.connection, ActiveFedora.fedora.host + ActiveFedora.fedora.base_path)
    # GET could be slow if it's a big resource, we're using HEAD to avoid this problem,
    # but this causes more requests to Fedora.
    return [] unless resource.head.rdf_source?

    descendant_uris = ActiveFedora::Base.descendant_uris(ActiveFedora.fedora.base_uri)

    # map uri to id to make filtering types easier
    descendant_ids = descendant_uris.map { |uri| ActiveFedora::Base.uri_to_id(uri) }.compact

    # models have the 10 digit ids fron AF Noid so remove the longer ones
    model_ids = descendant_ids.reject { |id| id.length > model_id_length }

    # permissions have the longer ids
    permission_ids = descendant_ids.reject { |id| id.length <= model_id_length }

    # run the permission ids first so that solr has the permissions before the index is updated for the model
    update_group(permission_ids)

    # run the models
    update_group(model_ids)

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
        rescue
          logger.error "error processing #{id}"
        end
      end
    end
end
