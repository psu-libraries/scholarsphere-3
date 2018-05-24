# frozen_string_literal: true

require 'fileutils'
require 'open-uri'
# Overrides CurationConcerns to update the file set with the file's name
class IngestFileJob < ActiveJob::Base
  attr_reader :file_set, :filepath, :characterize_path

  queue_as CurationConcerns.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] filepath the cached file within the CurationConcerns.config.working_path
  # @param [User] user
  # @option opts [String] mime_type
  # @option opts [String] filename
  # @option opts [String] relation, ex. :original_file
  def perform(file_set, filepath, user, opts = {})
    @file_set = file_set
    @filepath = filepath
    @characterize_path = filepath
    relation = opts.fetch(:relation, :original_file).to_sym
    local_file = {}
    local_file[:original_name] = File.basename(@filepath)

    # ENV['REPOSITORY_FILESTORE'] = "/data"
    # 1. Ensure REPOSITORY_FILESTORE exists and is writable
    ensure_repository_filestore_exists
    # 2. Copy filepath to REPOSITORY_FILESTORE using a pairtree
    copy_object_to_repository_filestore

    # Wrap in an IO decorator to attach passed-in options
    local_file = Hydra::Derivatives::IoDecorator.new(File.open(filepath, 'rb'))
    local_file.mime_type = opts.fetch(:mime_type, nil)
    local_file.original_name = opts.fetch(:filename, File.basename(filepath))

    add_file(relation, local_file)

    # Ensure the file set's title and label are the same as the filename
    @file_set.title = [local_file.original_name]
    @file_set.label = local_file.original_name

    # Persist changes to the file_set
    @file_set.save!

    repository_file = @file_set.files.first

    # Do post file ingest actions
    CurationConcerns::VersioningService.create(repository_file, user)

    # TODO: this is a problem, the file may not be available at this path on another machine.
    # It may be local, or it may be in s3

    CharacterizeJob.perform_later(@file_set, repository_file.id, @characterize_path)
  end

  def ensure_repository_filestore_exists
    FileUtils::mkdir_p ENV['REPOSITORY_FILESTORE']
  end

  # Given an ActiveFedora object, generate a pair tree
  # path for it based on its id
  # @param [ActiveFedora::Base] object
  def self.pairtree_path(object)
    identifier = object.id
    "/#{identifier[0, 2]}/#{identifier[2, 2]}/#{identifier[4, 2]}/#{identifier[6, 2]}/#{identifier}"
  end

  def self.object_path(object)
    ENV['REPOSITORY_FILESTORE'] + pairtree_path(object)
  end

  def ensure_object_directory_exists(object)
    FileUtils::mkdir_p IngestFileJob.object_path(object)
  end

  def copy_object_to_repository_filestore
    ensure_object_directory_exists(@file_set)
    FileUtils::cp @filepath, IngestFileJob.object_path(@file_set)
  end

  def self.pairtree_http_path(object, filepath)
    ENV['REPOSITORY_FILESTORE_HOST'] + IngestFileJob.pairtree_path(object) + '/' + File.basename(filepath)
  end

  def add_file(relation, local_file)
    if ENV['REPOSITORY_EXTERNAL_FILES'] == 'true'
      # Tell AddFileToFileSet service to skip versioning because versions will be minted by
      # VersionCommitter when necessary during save_characterize_and_record_committer.
      Hydra::Works::AddExternalFileToFileSet.call(@file_set,
                                                IngestFileJob.pairtree_http_path(@file_set, @filepath),
                                                relation,
                                                versioning: false)
      @characterize_path = ENV['REPOSITORY_FILESTORE_HOST'] + '/' + File.basename(@filepath)
    else
      # Tell AddFileToFileSet service to skip versioning because versions will be minted by
      # VersionCommitter when necessary during save_characterize_and_record_committer.
      Hydra::Works::AddFileToFileSet.call(@file_set,
                                        local_file,
                                        relation,
                                        versioning: false)
    end
  end
end
