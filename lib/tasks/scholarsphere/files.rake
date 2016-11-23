namespace :scholarsphere do
  namespace :files do

    desc "Creates derivatives, including thumbnails for all file sets, or using a list of ids separated by spaces"
    task :create_derivatives, [:list] => :environment do |_cmd, args|
      service = FileSetManagementService.new(args.fetch(:list, "").split(/ /))
      service.create_derivatives
      if service.errors > 0
        puts "#{service.errors} FileSet(s) failed to process, check the Rails log"
      else
        puts "Success!"
      end 
    end

    desc "Characterize all file sets, or supply a list of ids separated by spaces"
    task :characterize, [:list] => :environment do |_cmd, args|
      service = FileSetManagementService.new(args.fetch(:list, "").split(/ /))
      service.characterize
      if service.errors > 0
        puts "#{service.errors} FileSet(s) failed to process, check the Rails log"
      else
        puts "Success!"
      end 
    end
  end
end
