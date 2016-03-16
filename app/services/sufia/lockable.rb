# frozen_string_literal: true
# Monkeypatch Sufia::Lockable to use a Redis 2.4-compatible lock manager.
# Remove this when we've upgraded to Redis 2.6+
module Sufia
  module Lockable
    extend ActiveSupport::Concern

    def acquire_lock_for(lock_key, &block)
      lock_manager.lock(lock_key, &block)
    end

    def lock_manager
      @lock_manager ||= ::ScholarsphereLockManager.new
    end
  end
end
