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
Hydra::Derivatives::ShellBasedProcessor::ClassMethods.class_eval do

  alias_method :old_execute, :execute
  def execute(command)
    timeout = 10*60 # 10 minutes
    wait_thr = nil
    begin
      status = Timeout::timeout(timeout) do
        stdin, stdout, stderr, wait_thr = popen3(command)
        stdin.close
        out = stdout.read
        stdout.close
        err = stderr.read
        stderr.close
        raise "Unable to execute command \"#{command}\"\n#{err}" unless wait_thr.value.success?
      end
    rescue Timeout::Error => ex
      pid = wait_thr[:pid]
      Process.kill("TERM", pid)
      raise "Unable to execute command \"#{command}\"\nThe command took longer than #{ActionView::Base.new().time_ago_in_words(timeout.seconds.from_now)} to execute"
    end
  end
end
