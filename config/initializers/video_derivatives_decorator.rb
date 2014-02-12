Hydra::Derivatives::Video.class_eval do

  def codecs(format)
    case format
      when 'mp4'
        "-vcodec libx264 -acodec libvorbis"
      when 'webm'
        "-vcodec libvpx -acodec libvorbis"
      when "mkv"
        "-vcodec ffv1"
      else
        raise ArgumentError, "Unknown format `#{format}'"
    end
  end

end