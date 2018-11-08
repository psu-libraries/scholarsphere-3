# frozen_string_literal: true

# This module overrides certain methods in Hydra::Controller::DownloadBehavior to enable downloading of
# external content in Fedora.
module ExternalDownloadBehavior
  def show
    af_file = file.is_a?(ActiveFedora::File)
    if af_file && file.new_record?
      render_404
    else
      if af_file
        file.mime_type ||= 'text/plain'
        if response
          response.headers['Content-Length'] = file.size.to_i.to_s
        end
      end
      super
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
