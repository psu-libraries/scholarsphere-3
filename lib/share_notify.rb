# frozen_string_literal: true
module ShareNotify
  autoload :NotifyAPI,    'share_notify/notify_api'
  autoload :Metadata,     'share_notify/metadata'
  autoload :PushDocument, 'share_notify/push_document'

  class << self
    def configure(value)
      if value.nil? || value.is_a?(Hash)
        @config = value
      elsif value.is_a?(String)
        @config = YAML.load(File.read(value))
      else
        raise InitializationError, "Unrecognized configuration: #{value.inspect}"
      end
    end

    def config
      if @config.nil?
        configure(File.join(Rails.root.to_s, 'config', 'share_notify.yml'))
      end
      @config
    end
  end
end
