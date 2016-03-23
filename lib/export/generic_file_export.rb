require "./lib/export/permissions.rb"
require "./lib/export/versions_from_graph.rb"

module Export
  class GenericFileExport
    # Properties to be exported
    attr_accessor :id, :label, :depositor, :arkivo_checksum, :relative_path,
                  :import_url, :resource_type, :title, :creator, :contributor,
                  :description, :tag, :rights, :publisher, :date_created, :date_uploaded,
                  :date_modified, :subject, :language, :identifier, :based_near,
                  :related_url, :batch_id, :visibility, :versions
    attr_accessor :bibliographic_citation, :source
    attr_accessor :permissions

    # Don't export this. Let the file be re-characterized in Sufia 7.
    #
    # attr_accessor :characterization
    # contains 'full_text'
    # contains "thumbnail"

    # The content is fetched from Sufia 7 at the time the GenericFile is imported
    # contains "content", class_name: 'FileContentDatastream'

    def initialize(gf)
      @id = gf.id
      @label = gf.label
      @depositor = gf.depositor
      @arkivo_checksum = gf.arkivo_checksum
      @relative_path = gf.relative_path
      @import_url = gf.import_url
      @resource_type = gf.resource_type
      @title = gf.title
      @creator = gf.creator
      @contributor = gf.contributor
      @description = gf.contributor
      @tag = gf.tag
      @rights = gf.rights
      @publisher = gf.publisher
      @date_created = gf.date_created
      @date_uploaded = gf.date_uploaded
      @date_modified = gf.date_modified
      @subject = gf.subject
      @language = gf.language
      @identifier = gf.identifier
      @based_near = gf.based_near
      @related_url = gf.related_url
      @bibliographic_citation = gf.bibliographic_citation
      @source = gf.source
      @batch_id = gf.batch.id if gf.batch
      @visibility = gf.visibility
      # @characterization = Export::Characterization.new(gf)
      @versions = []
      if gf.content.has_versions?
        @versions = Export::VersionsFromGraph.parse(gf.content.versions)
      end
      @permissions = Export::Permissions.new(gf.permissions).to_a
    end

    def to_json(pretty = false)
      return super unless pretty
      JSON.pretty_generate(JSON.parse(to_json))
    end
  end
end
