# frozen_string_literal: true

require 'fileutils'
require 'logger'

class ExternalFilesConversion
  NUMBER_OF_PIDS_PER_FILE = 1000
  attr_reader :work_class, :user, :pid_lists, :error_file, :logger, :large_object_limit, :retry_time

  def initialize(work_class, large_object_limit = 3.gigabytes, retry_time = 1.second)
    @work_class = work_class
    @user = User.batch_user
    @logger = Logger.new(ENV['REPOSITORY_MIGRATION_LOG'] || Rails.root.join('log', "external_files_conversion_#{timestamp}.log").to_s)
    logger.level = Logger::DEBUG
    @pid_lists = []
    @error_file = ENV['REPOSITORY_MIGRATION_ERROR_LOG'] || Rails.root.join('log', "external_files_conversion_errors_#{timestamp}.log").to_s
    @large_object_limit = large_object_limit
    @retry_time = retry_time
    ActiveFedora.fedora.connection.http.options[:timeout] = 500
  end

  def timestamp
    @timestamp ||= Time.now.strftime('%Y-%m-%d-%H-%M-%S')
  end

  # If we receive a work ID, only convert that one item
  # If we receive a file of IDs, convert that list
  # Otherwise, convert all instances of the given class
  # @param [Hash] opts optional parameters. Valid values are :id and :file
  def convert(opts = {})
    start_time = Time.now
    logger.info "Starting conversion process at #{start_time}"
    if opts[:id]
      convert_work(opts[:id])
    elsif opts[:file]
      convert_from_file(opts[:file])
    elsif opts[:lists]
      create_lists
    else
      convert_class
    end
    end_time = Time.now
    elapsed_time = end_time - start_time
    logger.info "Finished conversion process at #{end_time}"
    logger.info "Elapsed time: #{elapsed_time}"
  end

  private

    def small_objects
      @small_results ||= all_objects.reject { |item| item['bytes_lts'] > large_object_limit }.map(&:id)
    end

    def large_objects
      @large_results ||= all_objects.reject { |item| item['bytes_lts'] <= large_object_limit }.map(&:id)
    end

    # Get a list of all of the objects of type @work_class from solr
    # return [Array]
    def all_objects
      @all_objects ||= ActiveFedora::SolrService.query('has_model_ssim:GenericWork', fl: 'id,bytes_lts', rows: GenericWork.count + 100)
    end

    # Create lists of PIDs for conversion, so that we can break the full export
    # down into smaller pieces
    # @return [Array] an array of the files that were created
    def create_lists
      pid_files_dir = Rails.root.join('tmp', 'external_files_conversion', timestamp)
      FileUtils.mkdir_p pid_files_dir
      file_path = "#{pid_files_dir}/large_objects.txt"
      File.open(file_path, 'w') { |file| file.puts(large_objects) }
      lists_of_pids = small_objects.each_slice(NUMBER_OF_PIDS_PER_FILE).to_a
      lists_of_pids.each_with_index do |list, index|
        file_path = "#{pid_files_dir}/#{index}.txt"
        File.open(file_path, 'w') { |file| file.puts(list) }
        pid_lists << file_path
      end
    end

    # Convert all works of a given work type
    # Do this by first creating lists of the pids to work from, then running
    # each of these individually, so we don't run out of memory. Pause between
    # files.
    def convert_class
      logger.info "Converting #{all_objects.count} objects of type #{@work_class}"
      create_lists
      pid_lists.each do |list|
        convert_from_file(list)
        sleep 10.minutes if Rails.env.production?
      end

      large_objects.each do |work_id|
        convert_work(work_id)
        sleep 1.minute if Rails.env.production?
      end
    end

    def convert_from_file(file)
      logger.error "Unable to find file #{file}" unless File.exists?(file)
      work_array = File.readlines(file).each(&:chomp!)
      logger.info "Converting contents of file #{file}"
      logger.info "Converting #{work_array.count} objects of type #{@work_class}"
      work_array.each do |work_id|
        convert_work(work_id)
      end
    end

    # param [String] work_id the id of the work to convert
    def convert_work(work_id)
      logger.info "Starting to convert work #{work_id}"
      begin
        work = ActiveFedora::Base.find(work_id)
        if already_converted?(work)
          logger.info "#{work_id} was previously converted"
          return true
        end
        if work.file_sets.blank?
          logger.warn "#{work_id} contains no files"
          return true
        end
        work.file_sets.each do |file_set|
          convert_fileset(work, file_set)
        end
        logger.info "Finished converting work #{work_id}"
      rescue ActiveFedora::ObjectNotFoundError => error
        logger.error "error finding object to migrate: #{work_id}; #{error}"
        File.open(@error_file, 'a') { |e| e.puts(work_id) }
      rescue StandardError => error
        logger.error "error migrating object: #{work_id}; #{error}"
        logger.error error.backtrace

        File.open(@error_file, 'a') { |e| e.puts(work_id) }
      end
    end

    # Test whether a given work_id has already been converted to
    # external file storage
    # @param [ActiveFedora::Base] work
    # @return [Boolean]
    def already_converted?(work)
      ldp_response = ActiveFedora.fedora.connection.head(work.file_sets.first.original_file.uri.to_s)
      ldp_response.response.status == 307 # Temporary Redirect
    end

    def convert_fileset(work, file_set)
      if file_set.extracted_text.present?
        file_set.extracted_text.destroy
        file_set.reload
      end

      # convert original file
      convert_file(work, file_set, file_set.original_file)
    end

    def convert_file(work, file_set, file)
      # This slug must be prefixed with auto_ so that it will not appear in versions.all
      begin
        ActiveFedora.fedora.connection.post(file.uri + '/fcr:versions', nil, slug: 'auto_placeholder')
      rescue Ldp::Conflict
        logger.warn "Work #{work.id} already had a version called 'auto_placeholder'. Perhaps it was previously converted?"
      end
      version_contents = []
      version_checksums = []

      download_versions(file: file, version_contents: version_contents, version_checksums: version_checksums)

      delete_versions(file: file)

      upload_versions(file: file, file_set: file_set, version_contents: version_contents)

      disk_checksums = calculate_disk_checksums(file: file)

      if disk_checksums != version_checksums
        raise "There was a checksum mismatch when converting the work with ID: #{work.id}, File: #{file.id}, Original Checksums #{version_checksums}, New Checksums #{disk_checksums}, output files #{version_contents}"
      end

      # clean up the contents
      version_contents.each do |content|
        begin
          File.delete(content)
        rescue StandardError
          logger.warn("could not delete #{content}")
        end
      end
    end

    def write_version_content(version_uri)
      version_file_name = filename_from_content_disposition(get_head(version_uri).headers['content-disposition'])
      time_stamp = Time.now.to_f.to_s
      file_path = Rails.root.join('tmp', 'external_internal_conversion', version_uri.split('/').last, time_stamp)
      FileUtils.mkdir_p(file_path)

      file = File.new(file_path.join(version_file_name), 'wb+')
      ActiveFedora.fedora.connection.open(version_uri) { |f| f.each_line { |line| file.write(line) } }
      file_path = File.absolute_path(file.path)
      file.close
      file_path
    end

    def filename_from_content_disposition(content_disposition)
      content_disposition.split(';')[1].split('filename=')[1].split('"')[1]
    end

    def get_head(uri)
      ActiveFedora.fedora.connection.head(uri).response
    end

    def get_file_name_from_metdata(uri)
      response = ActiveFedora.fedora.connection.get(uri + '/fcr:metadata')
      version_uri = ''
      response.each_statement { |statement| version_uri = statement.object if statement.predicate == 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#filename' }
      file_name = version_uri.to_s.gsub(ENV['REPOSITORY_FILESTORE_HOST'], ENV['REPOSITORY_FILESTORE'])
      file_name
    end

    def get_version(version)
      check_sum = ActiveFedora::FixityService.new(version.uri).expected_message_digest.gsub('urn:sha1:', '')
      version_content = write_version_content(version.uri)

      { check_sum: check_sum, version_content: version_content }
    end

    def download_versions(file:, version_contents:, version_checksums:)
      # download all versions and gather fixity
      file.versions.all.each do |version|
        tries = 0
        status = false
        while !status
          begin
            tries += 1
            result = get_version(version)
            version_checksums << result[:check_sum]
            version_contents << result[:version_content]
            status = true
          rescue StandardError => error
            if tries < 5
              logger.warn("Getting version on try # #{tries} issue: #{error.class} #{error}")
              sleep(tries * 5 * retry_time)
            else
              raise
            end
          end
        end
      end
    end

    def upload_versions(file:, file_set:, version_contents:)
      version_contents.each do |version_content|
        tries = 0
        status = false
        while !status
          begin
            tries += 1
            file_set.reload
            IngestFileJob.perform_now(file_set, version_content, @user)
            status = true
          rescue StandardError => error
            if tries < 5
              logger.warn("Issue saving version on try # #{tries} issue: #{error.class} #{error}")
              sleep(tries * 5 * retry_time)
            else
              raise
            end
          end
        end
      end
      ActiveFedora.fedora.connection.delete(file.uri + '/fcr:versions/auto_placeholder')
    end

    def delete_versions(file:)
      # delete all versions after we have gathered the data successfully
      file.versions.all.each do |version|
        ActiveFedora.fedora.connection.delete(version.uri)
      end
    end

    def calculate_disk_checksums(file:)
      disk_checksums = []
      reloaded_file = Hydra::PCDM::File.find(file.id)
      reloaded_file.versions.all.each do |version|
        disk_checksums << Digest::SHA1.file(get_file_name_from_metdata(version.uri)).hexdigest
      end
      disk_checksums
    end
end
