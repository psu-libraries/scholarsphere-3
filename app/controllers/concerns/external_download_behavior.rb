# frozen_string_literal: true

# This module overrides certain methods in Hydra::Controller::DownloadBehavior to enable downloading of
# external content in Fedora.
module ExternalDownloadBehavior
  def show
    case file
    when ActiveFedora::File
      if file.new_record?
        render_404
      else
        send_data file.content.read, type: file.mime_type, filename: file_name
      end
    when String
      # For derivatives stored on the local file system
      response.headers['Accept-Ranges'] = 'bytes'
      response.headers['Content-Length'] = File.size(file).to_s
      send_file file, derivative_download_options
    else
      render_404
    end
  end

  private

    # Override this if you'd like a different filename
    # @return [String] the filename
    def file_name
      if file.original_name.starts_with?('http')
        file.original_name.match(/[^\/]+$/)[0]
      else
        file.original_name
      end
    end
end
