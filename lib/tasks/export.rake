require "./lib/export/service.rb"

desc "Export the metadata for each generic file to a JSON file"
task :export => :environment do
  ids = Export::Service.fetch_ids(GenericFile)
  Export::Service.export ids, "./"
end

desc "Export all the IDs"
task :all_ids => :environment do
  puts "All IDs"
  puts Export::Service.fetch_ids
  puts "--"
end

desc "Export all GenericFile IDs"
task :gf_ids => :environment do
  puts "Generic File IDs"
  puts Export::Service.fetch_ids(GenericFile) # ::Batch, ::Collection
  puts "--"
end