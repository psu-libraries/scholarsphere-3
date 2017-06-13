# frozen_string_literal: true
rails_env = ENV['RAILS_ENV'] || 'development'

config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)['resque'].with_indifferent_access
Resque.redis = Redis.new(config.merge(thread_safe: true))
Resque.inline = rails_env == 'test'
Resque.redis.namespace = "scholarsphere:#{rails_env}"
Resque.logger.level = Logger::INFO
