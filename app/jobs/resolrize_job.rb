# frozen_string_literal: true
class ResolrizeJob
  def queue_name
    :resolrize
  end

  def run
    resource = Ldp::Resource::RdfSource.new(ActiveFedora.fedora.connection, ActiveFedora.fedora.host + ActiveFedora.fedora.base_path)
    # GET could be slow if it's a big resource, we're using HEAD to avoid this problem,
    # but this causes more requests to Fedora.
    return [] unless Ldp::Response.rdf_source?(resource.head)
    immediate_descendant_uris = resource.graph.query(predicate: ::RDF::Vocab::LDP.contains).map { |descendant| descendant.object.to_s }

    # map uri to id to make filtering types easier
    immediate_descendant_ids = immediate_descendant_uris.map { |uri| ActiveFedora::Base.uri_to_id(uri) }

    # models have the 9 digit ids fron AF Noid so remove the longer ones
    model_ids = immediate_descendant_ids.reject { |id| id.length > 9 }

    # permissions have the longer ids
    permission_ids = immediate_descendant_ids.reject { |id| id.length <= 9 }

    # run the permission ids first so that solr has the permissions before the index is updated for the model
    update_group(permission_ids)

    # run the models
    update_group(model_ids)
  end

  private

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
