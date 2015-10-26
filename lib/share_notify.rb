module ShareNotify

  autoload :API,      'share_notify/api'
  autoload :Metadata, 'share_notify/metadata'
  
  class << self
    def configure(value)
      if value.nil? or value.kind_of?(Hash)
        @config = value
      elsif value.kind_of?(String)
        @config = YAML.load(File.read(value))
      else
        raise InitializationError, "Unrecognized configuration: #{value.inspect}"
      end
    end

    def config
      if @config.nil?
        configure(File.join(Rails.root.to_s,'config','share_notify.yml'))
      end
      @config
    end
  end

end
