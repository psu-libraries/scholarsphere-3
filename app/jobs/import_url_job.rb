# frozen_string_literal: true

# Overrides the CurationConcerns job to accept the remote file's original name and handle failures.
#
# The file is downloaded using its original name and extension, but sanitized with CarrierWave to
# remove any non-alphanumeric characters. This is the same process that occurs with locally
# uploaded files (via CarrierWave) and avoids problems later when interacting with filenames
# that have unsupported characters.
#
# Additionally, if the job encounters any issues when downloading the file, such as an expired
# url or a timeout, the file set's name is changed to reflect the error.

require 'uri'
require 'tempfile'
require 'browse_everything/retriever'

class ImportUrlJob < ApplicationJob
  queue_as CurationConcerns.config.ingest_queue_name

  before_enqueue do |job|
    log = job.arguments.last
    log.pending_job(job)
  end

  # @param [FileSet] file_set
  # @param [String] file_name
  # @param [CurationConcerns::Operation] log to send messages
  def perform(file_set, file_name, log)
    log.performing!
    user = User.find_by_user_key(file_set.depositor)
    File.open(File.join(Dir.tmpdir, CarrierWave::SanitizedFile.new(file_name).filename), 'w+') do |f|
      importer = UrlImporter.new(file_set.import_url, f)

      unless importer.success?
        file_set.title = [I18n.t('scholarsphere.import_url.failed_title', file_name: file_name)]
        file_set.errors.add(
          'Error:',
          I18n.t('scholarsphere.import_url.failed_message', link: file_link(file_name, file_set.id),
                                                            message: importer.error)
        )
        on_error(log, file_set, user)
        return false
      end

      file_set.reload

      if CurationConcerns::Actors::FileSetActor.new(file_set, user).create_content(f)
        CurationConcerns.config.callback.run(:after_import_url_success, file_set, user)
        log.success!
      else
        on_error(log, file_set, user)
      end
    end
  end

  protected

    def on_error(log, file_set, user)
      CurationConcerns.config.callback.run(:after_import_url_failure, file_set, user)
      log.fail!(file_set.errors.full_messages.join(' '))
    end

    def file_link(file_name, id)
      ActionController::Base.helpers.link_to(
        file_name,
        Rails.application.routes.url_helpers.curation_concerns_file_set_path(id)
      )
    end

    class UrlImporter
      attr_reader :url, :file, :error

      # @param [String] url
      # @param [File] file
      def initialize(url, file)
        @url = url
        @file = file
      end

      def success?
        return false unless active_url?

        copy_remote_file
      end

      # @return [Boolean]
      # Checks to see if the remote url is active and valid
      def active_url?
        status = HTTParty.head(url).success?
        @error = 'Expired URL' unless status
        status
      end

      # @return [Boolean]
      # Downloads the remote file from the url to the file
      def copy_remote_file
        file.binmode
        retriever = BrowseEverything::Retriever.new
        retriever.retrieve('url' => url) { |chunk| file.write(chunk) }
        file.rewind
        true
      rescue StandardError => e
        @error = e.message
        false
      end
    end
end
