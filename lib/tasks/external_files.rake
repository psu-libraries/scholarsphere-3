# frozen_string_literal: true

namespace :scholarsphere do
  namespace :external_files do
    # adding a logger since it got removed from our gemset
    def logger
      Rails.logger
    end

    desc 'Create lists of pids to convert'
    task 'create_lists' => :environment do
      converter = ExternalFilesConversion.new(GenericWork)
      converter.convert(lists: true)
      puts 'Created the following files:'
      converter.pid_lists.each do |file|
        puts file
      end
    end

    desc 'Convert files stored internally in Fedora to externally on the filesystem'
    task 'internal_to_external_files' => :environment do
      unless ENV['REPOSITORY_EXTERNAL_FILES'] == 'true'
        puts 'You must set the REPOSITORY_EXTERNAL_FILES environment variable to true'
        puts 'before running this task'
        exit
      end
      puts 'This task will create a new version of all the works.'
      puts "The process will place the content in the #{ENV['REPOSITORY_FILESTORE']} directory."
      puts 'Are you sure you want to do this? (y/n)'

      if STDIN.gets.strip == 'y'
        ExternalFilesConversion.new(GenericWork).convert
      else
        puts 'You didn\'t reply with (y) so this rake task is exiting'
      end
    end
  end
end
