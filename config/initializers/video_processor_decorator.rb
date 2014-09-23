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
    puts "got to override"
    timeout = 5*60 # 5 minutes
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
      Process.kill("KILL", pid)
      raise "Unable to execute command \"#{command}\"\nThe command took longer than #{timeout} to execute"
    end
  end
end
