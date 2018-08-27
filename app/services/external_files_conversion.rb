# frozen_string_literal: true

require 'fileutils'
require 'logger'

class ExternalFilesConversion
  attr_reader :work_class, :user

  def initialize(work_class)
    @work_class = work_class
    @user = User.batch_user
    @logger = Logger.new(ENV['REPOSITORY_MIGRATION_LOG'])
    @logger.level = Logger::DEBUG
  end

  # If we receive a work ID, only convert that one item
  # If we receive a file of IDs, convert that list
  # Otherwise, convert all instances of the given class
  # @param [Hash] opts optional parameters. Valid values are :id and :file
  def convert(opts = {})
    start_time = Time.now
    @logger.info "Starting conversion process at #{start_time}"
    if opts[:id]
      convert_work(opts[:id])
    elsif opts[:file]
      convert_from_file(opts[:file])
    else
      convert_class
    end
    end_time = Time.now
    elapsed_time = end_time - start_time
    @logger.info "Finished conversion process at #{end_time}"
    @logger.info "Elapsed time: #{elapsed_time}"
  end

  private

    def convert_class
      all_objects = ActiveFedora::SolrService.query("has_model_ssim:#{@work_class}", fl: 'id', rows: 1000000).map(&:id)
      all_objects_count = all_objects.count
      @logger.info "Converting #{all_objects_count} objects of type #{@work_class}"
      all_objects.each do |work_id|
        convert_work(work_id)
      end
    end

    def convert_from_file(file)
      @logger.error "Unable to find file #{file}" unless File.exists?(file)
      work_array = File.readlines(file).each(&:chomp!)
      @logger.info "Converting contents of file #{file}"
      @logger.info "Converting #{work_array.count} objects of type #{@work_class}"
      work_array.each do |work_id|
        convert_work(work_id)
      end
    end

    # param [String] work_id the id of the work to convert
    def convert_work(work_id)
      @logger.info "Starting to convert work #{work_id}"
      begin
        work = ActiveFedora::Base.find(work_id)
        work.file_sets.each do |file_set|
          file_set.files.each do |file|
            convert_file(work, file_set, file)
          end
        end
      rescue ActiveFedora::ObjectNotFoundError => error
        @logger.error "error finding object to migrate: #{work_id}; #{error}"
      rescue StandardError => error
        @logger.error "error migrating object: #{work_id}; #{error}"
      end
      @logger.info "Finished converting work #{work_id}"
    end

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
