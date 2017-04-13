# frozen_string_literal: true
require 'uri'
require 'tempfile'
require 'browse_everything/retriever'

class ImportUrlJob < ActiveJob::Base
  queue_as CurationConcerns.config.ingest_queue_name

  before_enqueue do |job|
    log = job.arguments.last
    log.pending_job(job)
  end

  # @param [FileSet] file_set
  # @param [String] file_name
  # @param [CurationConcerns::Operation] log to send messages
  # Overrides the CurationConcerns job to accept the remote file's original name. The file
  # is downloaded using its original name and extension, but sanitized with CarrierWave to
  # remove any non-alphanumeric characters. This is the same process that occurs with locally
  # uploaded files (via CarrierWave) and avoids problems later when interacting with filenames
  # that have unsupported characters.
  def perform(file_set, file_name, log)
    log.performing!
    user = User.find_by_user_key(file_set.depositor)

    File.open(File.join(Dir.tmpdir, CarrierWave::SanitizedFile.new(file_name).filename), "w+") do |f|
      copy_remote_file(file_set, f)

      # reload the FileSet once the data is copied since this is a long running task
      file_set.reload

      # attach downloaded file to FileSet stubbed out
      if CurationConcerns::Actors::FileSetActor.new(file_set, user).create_content(f)
        # send message to user on download success
        CurationConcerns.config.callback.run(:after_import_url_success, file_set, user)
        log.success!
      else
        CurationConcerns.config.callback.run(:after_import_url_failure, file_set, user)
        log.fail!(file_set.errors.full_messages.join(' '))
      end
    end
  end

  protected

    def copy_remote_file(file_set, f)
      f.binmode
      # download file from url
      uri = URI(file_set.import_url)
      spec = { 'url' => uri }
      retriever = BrowseEverything::Retriever.new
      retriever.retrieve(spec) do |chunk|
        f.write(chunk)
      end
      f.rewind
    end
end
