# frozen_string_literal: true

require 'fileutils'

class ExternalFilesConversion
  attr_reader :work_class, :user

  def initialize(work_class)
    @work_class = work_class
    @user = User.batch_user
  end

  def convert
    @work_class.all.each do |work|
      work.file_sets.each do |file_set|
        file_set.files.each do |file|
          convert_file(work, file_set, file)
        end
      end
    end
  end

  private

    def convert_file(work, file_set, file)
      # This slug must be prefixed with auto_ so that it will not appear in versions.all
      ActiveFedora.fedora.connection.post(file.uri + '/fcr:versions', nil, slug: 'auto_placeholder')
      version_contents = []
      file.versions.all.each do |version|
        version_content = write_version_content(version.uri)
        version_contents << version_content
        ActiveFedora.fedora.connection.delete(version.uri)
      end

      version_contents.each do |version_content|
        file_set.reload
        if work.file_sets.first.original_file.nil? == false
          IngestFileJob.perform_now(file_set, version_content, @user)
        end
      end
      ActiveFedora.fedora.connection.delete(file.uri + '/fcr:versions/auto_placeholder')
    rescue OpenURI::HTTPError
      Rails.logger.warn "Problem accessing the URI for GenericWork: #{work.id}"
    rescue Ldp::HttpError
      Rails.logger.warn "Problem accessing the Fedora URI for GenericWork #{work.id}"
    end

    def write_version_content(version_uri)
      version_file_name = filename_from_content_disposition(open(version_uri).meta['content-disposition'])
      time_stamp = Time.now.to_i.to_s
      FileUtils.mkdir_p(Rails.root.join('tmp', 'external_internal_conversion', time_stamp))

      file = File.new(Rails.root.join('tmp', 'external_internal_conversion', time_stamp, version_file_name), 'wb+')
      file.write open(version_uri).read
      file_path = File.absolute_path(file.path)
      file.close
      file_path
    end

    def filename_from_content_disposition(content_disposition)
      content_disposition.split(';')[1].split('filename=')[1].split('"')[1]
    end
end
