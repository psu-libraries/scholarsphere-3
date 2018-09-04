# frozen_string_literal: true

require 'fileutils'
require 'logger'

class ExternalFilesConversion
  NUMBER_OF_PIDS_PER_FILE = 1000
  attr_reader :work_class, :user, :pid_lists, :error_file, :logger

  def initialize(work_class)
    @work_class = work_class
    @user = User.batch_user
    @logger = Logger.new(ENV['REPOSITORY_MIGRATION_LOG'] || Rails.root.join('log', "external_files_conversion_#{timestamp}.log").to_s)
    logger.level = Logger::DEBUG
    @pid_lists = []
    @error_file = ENV['REPOSITORY_MIGRATION_ERROR_LOG'] || Rails.root.join('log', "external_files_conversion_errors_#{timestamp}.log").to_s
  end

  def timestamp
    @timestamp ||= Time.now.strftime('%Y-%m-%e-%H-%M-%S')
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

    # Get a list of all of the objects of type @work_class from solr
    # return [Array]
    def all_objects
      @all_objects ||= ActiveFedora::SolrService.query("has_model_ssim:#{@work_class}", fl: 'id', rows: 1000000).map(&:id)
    end

    # Create lists of PIDs for conversion, so that we can break the full export
    # down into smaller pieces
    # @return [Array] an array of the files that were created
    def create_lists
      pid_files_dir = Rails.root.join('tmp', 'external_files_conversion', timestamp)
      FileUtils.mkdir_p pid_files_dir
      lists_of_pids = all_objects.each_slice(NUMBER_OF_PIDS_PER_FILE).to_a
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
        work.file_sets.each do |file_set|
          file_set.files.each do |file|
            convert_file(work, file_set, file)
          end
        end
        logger.info "Finished converting work #{work_id}"
      rescue ActiveFedora::ObjectNotFoundError => error
        logger.error "error finding object to migrate: #{work_id}; #{error}"
        File.open(@error_file, 'a') { |e| e.puts(work_id) }
      rescue StandardError => error
        logger.error "error migrating object: #{work_id}; #{error}"
        File.open(@error_file, 'a') { |e| e.puts(work_id) }
      end
    end

    # Test whether a given work_id has already been converted to
    # external file storage
    # @param [ActiveFedora::Base] work
    # @return [Boolean]
    def already_converted?(work)
      response = Net::HTTP.get_response(URI(work.file_sets.first.files.first.uri.to_s))
      response.to_s =~ /HTTPTemporaryRedirect/
    end

    def convert_file(work, file_set, file)
      checksums = exisiting_checksums
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
      # Try to delete the auto_placeholder snapshot, but if it is the only version snapshot
      # it will raise an error. Ignore these.
      begin
        ActiveFedora.fedora.connection.delete(file.uri + '/fcr:versions/auto_placeholder')
      rescue StandardError
      end

      if disk_checksums != checksums
        logger.error "There was a checksum mismatch when converting the work with ID: #{work.id}"
      end
    end

    def write_version_content(version_uri)
      version_file_name = filename_from_content_disposition(open(version_uri).meta['content-disposition'])
      time_stamp = Time.now.to_i.to_s
      FileUtils.mkdir_p(Rails.root.join('tmp', 'external_internal_conversion', time_stamp))

      file = File.new(Rails.root.join('tmp', 'external_internal_conversion', time_stamp, version_file_name), 'wb+')
      open(version_uri) { |f| f.each_line { |line| file.write(line) } }
      file_path = File.absolute_path(file.path)
      file.close
      file_path
    end

    def filename_from_content_disposition(content_disposition)
      content_disposition.split(';')[1].split('filename=')[1].split('"')[1]
    end

    def exisiting_checksums
      Checksummer.new(work).fedora_checksums unless ENV['TRAVIS'] == 'true'
    end

    def disk_checksums
      Checksummer.new(work).disk_checksums unless ENV['TRAVIS'] == 'true'
    end
end
