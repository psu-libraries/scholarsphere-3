require "./lib/import/import_service.rb"

desc "Imports Sufia 6 GenericFiles into Sufia 7 GenericWorks"
task :import_sufia_6 => :environment do
  # Credentials for the Fedora instance with the content of the files to be imported
  # (this is the Fedora instance used by the *Sufia 6* application)
  user = "fedoraAdmin"
  password = "fedoraAdmin"
  root_uri = "http://localhost:8983/fedora/rest/dev"

  # Will be true for the real import
  # (leave as false so that we can re-run the import without running into duplicate IDs)
  preserve_ids = false

  # Set to true if you have a running instance of Fedora 4
  # with the source binaries. Leave as false if you are
  # only testing the metadata part of the import.
  import_binary = false

  # Files exported from Sufia 6
  files_to_import = File.join(Dir.pwd, "gf_*.json")

  settings = Importer::ImportSettings.new(user, password, root_uri, preserve_ids, import_binary)
  service = Importer::ImportService.new(settings)
  service.import(files_to_import)
end
