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
    immediate_descendant_uris.each do |uri|
      id = ActiveFedora::Base.uri_to_id(uri)
      logger.debug "Re-index everything ... #{id}"
      begin
        ActiveFedora::Base.find(id).update_index
      rescue
        logger.error "error processing #{id}"
      end
    end
  end
end
