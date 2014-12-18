require 'fedora-migrate'

module FedoraMigrate::Hooks

  # Apply depositor metadata and migrate the descMetadata datastream.
  # This is to ensure that we have any required fields such as title
  # present before the object is saved.
  def before_object_migration
    xml = Nokogiri::XML(source.datastreams["properties"].content)
    target.apply_depositor_metadata xml.xpath("//depositor").text
    migrate_desc_metadata if target.kind_of?(GenericFile) || target.kind_of?(Collection)
  end

  # call any after migration hooks we need here....
  def after_object_migration
  end

  def migrate_desc_metadata
    FedoraMigrate::RDFDatastreamMover.new(
      source.datastreams["descMetadata"], 
      target
    ).migrate
  end

end

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
