# frozen_string_literal: true
require "./lib/export/generic_file_export.rb"

module Export
  class Service
    def self.fetch_ids(klass = nil)
      root_uri = ActiveFedora::Base.id_to_uri('')
      all_uris = descendant_uris(root_uri).select { |uri| uri != root_uri }
      all_ids = all_uris.map { |uri| uri.split("/").last }
      return all_ids if klass.nil?
      # return only the ones that match the klass
      all_ids.select { |id| ActiveFedora::Base.find(id).class == klass }
    end

    # Exports each GenericFile to a JSON file in the specified path
    # Each JSON file is named gw_###.json (where ### is the Generic File's ID)
    def self.export(ids, path)
      ids.each do |id|
        file_name = File.join(path, "gf_#{id}.json")
        export_one_to_file(id, file_name)
      end
    end

    def self.export_one_to_file(id, file_name)
      gf = ::GenericFile.find(id)
      json = Export::GenericFileExport.new(gf).to_json(true)
      File.write(file_name, json)
    end

    # stolen from: https://github.com/projecthydra/active_fedora/blob/master/lib/active_fedora/indexing.rb#L72-L79
    def self.descendant_uris(uri = nil)
      resource = Ldp::Resource::RdfSource.new(ActiveFedora.fedora.connection, uri)
      return [] unless rdf_source?(resource)

      children = resource.graph.query(predicate: ::RDF::Vocab::LDP.contains).map { |descendant| descendant.object.to_s }
      descendants = [uri]
      children.each do |child_uri|
        descendants += descendant_uris(child_uri)
      end
      descendants
    end

    def self.rdf_source?(resource)
      link_header = resource.head.env.response.headers[:link]
      return false if link_header.include?("<http://www.w3.org/ns/ldp#NonRDFSource>")
      true
    end
  end
end
