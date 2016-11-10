# frozen_string_literal: true
require 'net/https'
require 'uri'
require 'tempfile'

class ImportUrlJob < ActiveFedoraIdBasedJob
  include Hydra::ModelMethods

  def queue_name
    :import_url
  end

  def run
    user = User.find_by_user_key(generic_file.depositor)

    uri = URI(generic_file.import_url)
    if uri.scheme == 'file'
      attach_local_file(user, uri)
    else
      attach_remote_file(user, uri)
    end
  end

  def copy_remote_file(uri, f)
    f.binmode
    # download file from url
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https" # enable SSL/TLS
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    mime_type = nil

    http.start do
      http.request_get(uri.request_uri) do |resp|
        mime_type = resp.content_type
        resp.read_body do |segment|
          f.write(segment)
        end
      end
    end

    f.rewind
    [uri.path, mime_type]
  end

  def job_user
    User.batchuser
  end

  private

    def attach_remote_file(user, uri)
      Tempfile.open(id.tr('/', '_')) do |f|
        path, mime_type = copy_remote_file(uri, f)

        # reload the generic file once the data is copied since this is a long running task
        generic_file.reload

        attach_file(user, f, path, mime_type)
        f
      end.unlink
    end

    def attach_local_file(user, uri)
      path = uri.path
      f = File.open(uri.path)
      mime_type = best_mime_for_filename(uri.path)
      attach_file(user, f, path, mime_type)
    end

    def attach_file(user, f, path, mime_type)
      # attach downloaded file to generic file stubbed out
      if Sufia::GenericFile::Actor.new(generic_file, user).create_content(f, path, 'content', mime_type)
        # add message to user for downloaded file
        message = "The file (#{generic_file.label}) was successfully imported."
        job_user.send_message(user, message, 'File Import')
      else
        job_user.send_message(user, generic_file.errors.full_messages.join(', '), 'File Import Error')
      end
    end
end
