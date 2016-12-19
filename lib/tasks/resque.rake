require 'resque/pool/tasks'

# This provides access to the Rails env within all Resque workers
task 'resque:setup' => :environment

# Set up resque-pool
task 'resque:pool:setup' do
  ActiveRecord::Base.connection.disconnect!
  Resque::Pool.after_prefork do |job|
    ActiveRecord::Base.establish_connection
    Resque.redis.client.reconnect
  end
end

desc "Retries the failed jobs and clears the current failed jobs queue at the same time"
task "resque:retry-failed-jobs" => :environment do
  i=0
  while job = Resque::Failure.all(i)
    if job["exception"] == "Resque::DirtyExit"
      Resque::Failure.requeue(i)
      Resque::Failure.remove(i) #does this work or mess up the rest????
    else
      i = i+1
    end
  end
end

