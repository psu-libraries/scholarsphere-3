require "./lib/export/service.rb"

# usage: rake gf_ids > gf_ids.txt
desc "Outputs to the console the IDs of all the Generic Files in Fedora 4"
task :gf_ids => :environment do
  puts Export::Service.fetch_ids(GenericFile)
end

# usage: rake export_gf[gf_ids.txt]
desc "Export the metadata for each generic file to a JSON file"
task :export_gf, [:id_file] => :environment do |cmd, args|
  file_name = args[:id_file]
  raise "Missing id_file parameter" if file_name.nil?
  ids = File.foreach(file_name).map { |line| line.chomp }
  Export::Service.export_generic_files ids, "./" do |id|
    puts "Processing generic file #{id}"
  end
end

# usage: rake export_coll[gf_ids.txt]
desc "Export the metadata for each collection to a JSON file"
task :export_coll, [:id_file] => :environment do |cmd, args|
  file_name = args[:id_file]
  raise "Missing id_file parameter" if file_name.nil?
  ids = File.foreach(file_name).map { |line| line.chomp }
  Export::Service.export_collections ids, "./" do |id|
    puts "Processing collection #{id}"
  end
end

# usage: rake coll_ids > coll_ids.txt
desc "Outputs to the console the IDs of all the Collections in Fedora 4"
task :coll_ids => :environment do
  puts Export::Service.fetch_ids(Collection)
end

desc "Outputs to the console the IDs of all the Fedora 4 objects"
task :all_ids => :environment do
  puts Export::Service.fetch_ids
end
