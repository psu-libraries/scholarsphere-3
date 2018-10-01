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

    desc 'Convert a list of pids stored internally in Fedora to externally on the filesystem'
    task 'convert_pid_file', [:pid_file] => :environment do |_cmd, args|
      pid_file = args[:pid_file]
      converter = ExternalFilesConversion.new(GenericWork)
      converter.convert(file: pid_file)
    end

    desc 'Validate that every object has been converted'
    task 'validate' => :environment do
      converter = ExternalFilesConversion.new(GenericWork)
      converter.validate
    end

    desc 'Validate that every files has been converted'
    task 'validate_files' => :environment do
      converter = ExternalFilesConversion.new(GenericWork)
      converter.validate_files
    end
  end
end
