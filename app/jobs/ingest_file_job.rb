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

    if ENV['REPOSITORY_EXTERNAL_FILES'] == 'true'
      # Whenever you upload a version, the filename option is set
      # if you upload new file it is not set
      local_file_name = opts.fetch(:filename, nil) || local_file[:original_name]

      @filepath = Scholarsphere::Pairtree.new(@file_set, Scholarsphere::Bagger).create_repository_files(@filepath, local_file_name)
    end

    # Wrap in an IO decorator to attach passed-in options
    local_file = Hydra::Derivatives::IoDecorator.new(File.open(filepath, 'rb'))
    local_file.mime_type = opts.fetch(:mime_type, nil)
    local_file.original_name = opts.fetch(:filename, File.basename(@filepath))

    add_file(relation, local_file)

    # Ensure the file set's title and label are the same as the filename
    @file_set.title = [local_file.original_name]
    @file_set.label = local_file.original_name

    # Persist changes to the file_set
    @file_set.save!

    repository_file = file_set.send(relation)

    # Do post file ingest actions
    CurationConcerns::VersioningService.create(repository_file, user)

    # TODO: this is a problem, the file may not be available at this path on another machine.
    # It may be local, or it may be in s3

    CharacterizeJob.perform_later(@file_set, repository_file.id, @characterize_path)
  end

  private

    # Tell AddFileToFileSet service to skip versioning because versions will be minted by
    # VersionCommitter when necessary during save_characterize_and_record_committer.
    def add_file(relation, local_file)
      if ENV['REPOSITORY_EXTERNAL_FILES'] == 'true'
        Hydra::Works::AddExternalFileToFileSet.call(@file_set,
                                                  Scholarsphere::Pairtree.new(@file_set, Scholarsphere::Bagger).http_path(@filepath),
                                                  relation,
                                                  versioning: false)
        Scholarsphere::Pairtree.new(@file_set, Scholarsphere::Bagger).http_path(@filepath)
      else
        Hydra::Works::AddFileToFileSet.call(@file_set,
                                          local_file,
                                          relation,
                                          versioning: false)
      end
    end
end
