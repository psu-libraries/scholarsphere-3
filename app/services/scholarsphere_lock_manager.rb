# frozen_string_literal: true
# Implements file-based locking which is incompatible with Redis 2.4
# Remove this when we've upgraded to Redis 2.6+
class ScholarsphereLockManager
  def lock(key)
    state_file = "#{ScholarSphere::Application.config.statefile}_#{key}"
    File.open(state_file, File::RDWR | File::CREAT, 0644) do |f|
      f.flock(File::LOCK_EX)
      yield
    end
  end
end
