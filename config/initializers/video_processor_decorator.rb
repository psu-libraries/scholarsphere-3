Hydra::Derivatives::Video.class_eval do

  def codecs(format)
    case format
      when 'mp4'
        "-vcodec mpeg4 -acodec libfdk_aac"
      when 'webm'
        "-vcodec libvpx -acodec libvorbis"
      when "mkv"
        "-vcodec ffv1"
      when "jpg"
        "-vcodec mjpeg"
      else
        raise ArgumentError, "Unknown format `#{format}'"
    end
  end

end