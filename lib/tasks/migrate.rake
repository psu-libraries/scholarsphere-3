require 'fedora-migrate'

namespace :scholarsphere do

  namespace :migrate do
    desc "Migrates all objects"
    task repository: :environment do
      results = FedoraMigrate.migrate_repository(namespace: "scholarsphere", options: {convert: "descMetadata"})
      puts results
    end
  

    desc "Migrate a single object"
    task :object, [:pid] => :environment do |t, args|
      raise "Please provide a pid, example changeme:1234" if args[:pid].nil?
      FedoraMigrate::ObjectMover.new(
        FedoraMigrate.source.connection.find(args[:pid]), 
        nil, 
        options: {convert: "descMetadata"}
      ).migrate
    end

  end

end
