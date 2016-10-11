namespace :scholarsphere do

  # Harvests authority terms from rdfxml files and loads them into tables
  # for integration with Questioning Authority.
  namespace :harvest do
    desc "Harvest LC subjects"
    task :lc_subjects, [:file] => :environment do |task, args|
      puts "Loading #{args.file} ..."
      RDFAuthorityImporter.import_subjects(args.file)
    end

    desc "Harvest Lexvo languages"
    task :lexvo_languages, [:file] => :environment do |task, args|
      puts "Loading #{args.file} ..."
      RDFAuthorityImporter.import_languages(args.file)
    end
  end
end
