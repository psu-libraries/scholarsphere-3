# frozen_string_literal: true

# This module overrides certain methods in Hydra::Controller::DownloadBehavior to enable downloading of
# external content in Fedora.
module ExternalDownloadBehavior
  def show
    case file
    when ActiveFedora::File
      # For original files that are stored in fedora

      if file.new_record?
        render_404
      else
        file.mime_type ||= 'text/plain'
        if response
          response.headers['Content-Length'] = file.size.to_i.to_s
        end
        super
      end
    when String
      # For derivatives or files stored on the local file system
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

    def file_path
      return unless remote?

      @file_path ||= Scholarsphere::Pairtree.new(asset, nil).storage_path(file_url)
    end

    def file_url
      @file_url ||= ActiveFedora.fedora.connection.head(file.uri).response.headers['content-type'].split('"')[1]
    end

    def attribute_url
      local_mime_type = metadata.attributes['http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasMimeType'].first
      local_mime_type.split('url="')[1][0..-2]
    end
end
