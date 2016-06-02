module Importer
  # TODO: Split these classes into individual files
  class ImportSettings
    attr_reader :sufia6_user, :sufia6_password, :sufia6_root_uri, :preserve_ids
    attr_reader :import_binary

    def initialize(sufia6_user, sufia6_password, sufia6_root_uri, preserve_ids, import_binary)
      @sufia6_user = sufia6_user
      @sufia6_password = sufia6_password
      @sufia6_root_uri = sufia6_root_uri
      @preserve_ids = preserve_ids
      @import_binary = import_binary
    end
  end

  class ImportPermission
    def self.from_gf(id, gf_perms)
      permissions = []
      gf_perms.each do |gf_perm|
        permissions << create(id, gf_perm)
      end
      permissions
    end

    def self.create(gw_id, gf_perm)
      agent = gf_perm.agent.split("/").last           # e.g. "http://projecthydra.org/ns/auth/person#hjc14"
      type = agent.split("#").first                   # e.g. person or group
      name = agent.split("#").last                    # e.g. hjc14 or public
      name += "@psu.edu" if type == "person"
      access = gf_perm.mode.split("#").last.downcase  # e.g. "http://www.w3.org/ns/auth/acl#Write"
      access = "edit" if access == "write"
      Hydra::AccessControls::Permission.new(id: gw_id, name: name, type: type, access: access)
    end
  end

  class ImportFileSet
    def initialize(settings)
      @settings = settings
    end

    def from_gf(gf, depositor)
      fs = FileSet.new
      fs.title << gf.title
      # Where did the filename property go?
      # fs.filename = gf.filename
      fs.label = gf.label
      fs.date_uploaded = gf.date_uploaded
      fs.date_modified = gf.date_modified
      fs.apply_depositor_metadata(depositor)
      fs.save!

      fs.permissions = ImportPermission.from_gf(fs.id, gf.permissions)
      fs.save!

      # File
      if @settings.import_binary
        import_old_versions(gf, fs)
        import_current_version(gf, fs)
      end

      fs
    end

    def sufia6_content_open_uri(id)
      content_uri = "#{@settings.sufia6_root_uri}/#{ActiveFedora::Noid.treeify(id)}/content"
      file = open(content_uri, http_basic_authentication: [@settings.sufia6_user, @settings.sufia6_password])
      file
    end

    def sufia6_version_open_uri(id, label)
      content_uri = "#{@settings.sufia6_root_uri}/#{ActiveFedora::Noid.treeify(id)}/content/fcr:versions/#{label}"
      file = open(content_uri, http_basic_authentication: [@settings.sufia6_user, @settings.sufia6_password])
      file
    end

    def import_current_version(gf, fs)
      # Download the current version to disk...
      filename_on_disk = "/Users/hjc14/dev/friday25/sufia/.internal_test_app/#{fs.label}"
      Rails.logger.debug "[IMPORT] Downloading #{filename_on_disk}"
      File.open(filename_on_disk, 'wb') do |file_to_upload|
        source_uri = sufia6_content_open_uri(gf.id)
        file_to_upload.write source_uri.read
      end

      # ...upload it...
      File.open(filename_on_disk, 'rb') do |file_to_upload|
        Hydra::Works::UploadFileToFileSet.call(fs, file_to_upload)
      end

      # ...and characterize it.
      # TODO: perform_now or perform_later?
      #       What's the risk of leaving too many files on disk?
      #       Delete filename_on_disk at the end.
      CharacterizeJob.perform_now(fs.id, filename_on_disk)
      CreateDerivativesJob.perform_now(fs.id, filename_on_disk)
    end

    def import_old_versions(gf, fs)
      return if gf.versions.count <= 1
      # Upload all versions before the current version
      # (notice that we don't characterize these versions)
      versions = gf.versions.sort_by(&:created)
      versions.pop
      versions.each do |version|
        source_uri = sufia6_version_open_uri(gf.id, version.label)
        Hydra::Works::UploadFileToFileSet.call(fs, source_uri)
      end
    end
  end

  class ImportGenericWork
    def initialize(settings)
      @settings = settings
    end

    def from_gf(gf, depositor)
      gw = GenericWork.new
      gw.id = gf.id if @settings.preserve_ids
      gw.apply_depositor_metadata(depositor)
      gw.label                  = gf.label
      gw.arkivo_checksum        = gf.arkivo_checksum
      gw.relative_path          = gf.relative_path
      gw.import_url             = gf.import_url
      gw.part_of                = gf.part_of
      gw.resource_type          = gf.resource_type
      gw.title                  = gf.title
      gw.creator                = gf.creator
      gw.contributor            = gf.contributor
      gw.description            = gf.description
      # Where did the tags go? Are they now in the FileSet?
      # gw.tag                    = gf.tag
      gw.rights                 = gf.rights
      gw.publisher              = gf.publisher
      gw.date_created           = gf.date_created
      gw.subject                = gf.subject
      gw.language               = gf.language
      gw.identifier             = gf.identifier
      gw.based_near             = gf.based_near
      gw.related_url            = gf.related_url
      gw.bibliographic_citation = gf.bibliographic_citation
      gw.source                 = gf.source
      gw.save! unless @settings.preserve_ids
      gw.permissions = ImportPermission.from_gf(gw.id, gf.permissions)
      gw.save!
      gw
    end
  end

  class ImportGenericFile
    attr_reader :settings

    def initialize(settings)
      @settings = settings
    end

    def import(gf)
      # This is needed because Sufia uses the full e-mail address (xyz@psu.edu) but ScholarSphere
      # uses only the login name (xyz). Here we make sure we match the Sufia convention. This
      # won't be needed when we run the import in ScholarSphere directly since the users we'll be
      # already in the db with the expected format (xyz@psu.edu)
      depositor = gf.depositor + "@psu.edu"

      # File Set + File
      fs = ImportFileSet.new(settings).from_gf(gf, depositor)

      # Generic Work
      gw = ImportGenericWork.new(settings).from_gf(gf, depositor)
      gw.ordered_members << fs
      gw.save!
      Rails.logger.debug "[IMPORT] Created generic work #{gw.id}"

      # TODO: set generic work thumbnail (shouldn't this happen automatically in create derivatives)
      gw
    end
  end

  class ImportCollection
    def initialize(settings)
      @settings = settings
    end

    def import(source)
      # This is needed because Sufia uses the full e-mail address (xyz@psu.edu) but ScholarSphere
      # uses only the login name (xyz). Here we make sure we match the Sufia convention. This
      # won't be needed when we run the import in ScholarSphere directly since the users we'll be
      # already in the db with the expected format (xyz@psu.edu)

      # TODO: include depositor in export
      depositor = "hjc14" + "@psu.edu"

      collection = Collection.new()
      collection.id = source.id if @settings.preserve_ids
      collection.title << source.title
      collection.apply_depositor_metadata(depositor)
      source.creator.each do |c|
        collection.creator << c
      end
      source.members.each do |gf_id|
        # Members of Sufia 6 collections were GenericFiles. For the ScholarSphere
        # import we are going to assume that the GenericFile that was part of the
        # original Sufia 6 Collection has been imported into Sufia 7 as a
        # *GenericWork* with the same ID as the original GenericFile.
        gw = GenericWork.find(gf_id)
        collection.members << gw
      end
      collection.save
      Rails.logger.debug "[IMPORT] Created collection #{collection.id}"
      collection
    end
  end

  class ImportService
    attr_reader :settings
    def initialize(settings)
      @settings = settings
    end

    def import(files_pattern)
      files = Dir.glob(files_pattern)
      Rails.logger.debug "[IMPORT] Processing #{files.count} files from #{files_pattern}..."
      files.each do |file_name|
        basename = File.basename(file_name)
        case
        when basename.start_with?("gf_")
          Rails.logger.debug "[IMPORT] Importing generic file: #{basename}"
          import_generic_file(file_name)
        when basename.start_with?("coll_")
          Rails.logger.debug "[IMPORT] Importing collection: #{basename}"
          import_collection(file_name)
        else
          Rails.logger.debug "[IMPORT] File #{basename} was ignored"
        end
      end
    end

    def import_generic_file(file_name)
      json = File.read(file_name)
      generic_file = JSON.parse(json, object_class: OpenStruct)
      ImportGenericFile.new(@settings).import(generic_file)
    end

    def import_collection(file_name)
      json = File.read(file_name)
      collection = JSON.parse(json, object_class: OpenStruct)
      ImportCollection.new(@settings).import(collection)
    end
  end
end
