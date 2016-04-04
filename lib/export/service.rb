# frozen_string_literal: true
require "./lib/export/generic_file_export.rb"
require "./lib/export/collection_export.rb"

module Export
  class Service
    class << self
      # Fetches the Fedora 4 IDs for all the objects that match the indicated klass
      def fetch_ids(klass = nil)
        root_uri = ActiveFedora::Base.id_to_uri('')
        all_uris = descendant_uris(root_uri).select { |uri| uri != root_uri }
        all_ids = all_uris.map { |uri| uri.split("/").last }
        return all_ids if klass.nil?
        # return only the ones that match the klass
        all_ids.select { |id| active_fedora_model(id) == klass.to_s }
      end

      # Exports each GenericFile to a JSON file in the specified path.
      # Each JSON file is named gw_###.json (where ### is the Generic File's ID)
      def export_generic_files(ids, path)
        ids.each do |id|
          yield id if block_given?
          file_name = File.join(path, "gf_#{id}.json")
          export_one_generic_file(id, file_name)
        end
      end

      # Exports each Collection to a JSON file in the specified path.
      # Each JSON file is named coll_###.json (where ### is the Collection's ID)
      def export_collections(ids, path)
        ids.each do |id|
          yield id if block_given?
          file_name = File.join(path, "coll_#{id}.json")
          export_one_collection(id, file_name)
        end
      end

      def export_one_collection(id, file_name)
        coll = ::Collection.find(id)
        json = Export::CollectionExport.new(coll).to_json(true)
        File.write(file_name, json)
      end

      def export_one_generic_file(id, file_name)
        gf = ::GenericFile.find(id)
        json = Export::GenericFileExport.new(gf).to_json(true)
        File.write(file_name, json)
      end

      # Fetches all the Fedora 4 descendant URIs for a given URI.
      # Stolen from: https://github.com/projecthydra/active_fedora/blob/master/lib/active_fedora/indexing.rb#L72-L79
      def descendant_uris(uri = nil)
        resource = Ldp::Resource::RdfSource.new(ActiveFedora.fedora.connection, uri)
        return [] unless rdf_source?(resource)

        children = resource.graph.query(predicate: ::RDF::Vocab::LDP.contains).map { |descendant| descendant.object.to_s }
        descendants = [uri]
        children.each do |child_uri|
          descendants += descendant_uris(child_uri)
        end
        descendants
      end

      def rdf_source?(resource)
        link_header = resource.head.env.response.headers[:link]
        return false if link_header.include?("<http://www.w3.org/ns/ldp#NonRDFSource>")
        true
      end

      def active_fedora_model(id)
        query = 'id:"' + id + '"'
        matches = ActiveFedora::SolrService.query(query)
        return nil if matches.count == 0
        matches.first["active_fedora_model_ssi"]
      end
    end
  end
end
