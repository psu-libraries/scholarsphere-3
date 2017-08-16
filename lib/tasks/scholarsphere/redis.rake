# frozen_string_literal: true

namespace :scholarsphere do
  namespace :redis do
    desc 'Migrates Redis keys to GenericWork types, removes SHARE events, and namespaces keys'
    task migrate: :environment do
      Redis.current.keys('*GenericFile*').each do |key|
        length = Redis.current.llen(key)
        Redis.current.lrange(key, 0, length).each do |id|
          if Redis.current.hgetall("events:#{id}").fetch('action', 'nothing') =~ /SHARE/
            Redis.current.lrem(key, 0, id)
            Redis.current.del("events:#{id}")
          end
        end
      end

      Redis.current.keys('*').each do |key|
        if key =~ /GenericFile/
          new_key = key.gsub(/GenericFile/, 'GenericWork')
          Redis.current.rename(key, "#{Sufia.config.redis_namespace}:#{new_key}")
        else
          Redis.current.rename(key, "#{Sufia.config.redis_namespace}:#{key}")
        end
      end

      Redis.current.save
    end
  end
end
