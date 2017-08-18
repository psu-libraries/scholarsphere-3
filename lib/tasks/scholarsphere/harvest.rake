# frozen_string_literal: true

namespace :scholarsphere do
  # Harvests authority terms from rdfxml files and loads them into tables
  # for integration with Questioning Authority.
  namespace :harvest do
    desc 'Harvest LC subjects'
    task :lc_subjects, [:file] => :environment do |_task, args|
      puts "Loading #{args.file} ..."
      SubjectAuthorityImportJob.perform_later(args.file)
    end

    desc 'Harvest Lexvo languages'
    task :lexvo_languages, [:file] => :environment do |_task, args|
      puts "Loading #{args.file} ..."
      LanguageAuthorityImportJob.perform_later(args.file)
    end
  end
end
