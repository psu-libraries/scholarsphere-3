require 'fedora-migrate'

module FedoraMigrate::Hooks
  # Apply depositor metadata
  def before_object_migration
    xml = Nokogiri::XML(source.datastreams["properties"].content)
    target.apply_depositor_metadata xml.xpath("//depositor").text
  end
end

namespace :scholarsphere do

  namespace :migrate do
    desc "Migrates all objects"
    task repository: :environment do
      migration_options = {convert: "descMetadata", force: true, application_creates_versions: true}
      migrator = FedoraMigrate.migrate_repository(namespace: "scholarsphere", options: migration_options )
      Rake::Task["sufia:migrate:proxy_deposits"].invoke
      Rake::Task["sufia:migrate:audit_logs"].invoke
    end
  

    desc "Migrate a single object"
    task :object, [:pid] => :environment do |t, args|
      raise "Please provide a pid, example changeme:1234" if args[:pid].nil?
      FedoraMigrate::ObjectMover.new(
        FedoraMigrate.source.connection.find(args[:pid]), 
        nil, 
        {convert: "descMetadata"}
      ).migrate
    end

    desc "fix csv files by converting the content to text"
    task :csv_fix, [:ids, :fedora_path] => :environment do |t, args|
      ids = args[:ids].split(';')
      fedora_path = args[:fedora_path]
      pred = RDF::URI.new('http://fedora.info/definitions/v4/repository#digest')
      ids.each  do |id|
        gf = GenericFile.find(id)
        sha = gf.content.metadata.ldp_source.graph.query(predicate: pred).first.object.to_s
        file_name = "#{fedora_path}/#{sha.slice(9,2)}/#{sha.slice(11,2)}/#{sha.slice(13,2)}/#{sha.slice(9,sha.length-9)}"
        file = File.open(file_name)
        actor = Sufia::GenericFile::Actor.new(gf, User.find_by(login:"cam156"))
        uploaded_file = ActionDispatch::Http::UploadedFile.new(tempfile:file)
        uploaded_file.original_filename = "#{gf.label}.fixed.txt"
        uploaded_file.content_type = "text/plain"
        actor.update_content(uploaded_file, "content")
      end
    end

  end

end
