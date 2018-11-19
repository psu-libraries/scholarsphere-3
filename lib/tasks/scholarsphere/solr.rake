# frozen_string_literal: true

namespace :scholarsphere do
  namespace :solr do
    desc 'Index a single object in solr'
    task :index, [:id] => :environment do |_t, args|
      raise 'Please provide a id' if args[:id].nil?
      ActiveFedora::Base.find(args[:id]).update_index
    end

    desc 'Compares number of objects in Solr with those in Fedora'
    task compare: :environment do
      fedora = number_of_objects_in_fedora
      solr = number_of_objects_in_solr
      raise "Fedora's #{fedora} objects exceeds Solr's #{solr}" if fedora > solr
      puts 'Things appear to be OK'
    end
  end

  def number_of_objects_in_fedora
    url = case Rails.env
          when 'test' then 'test'
          when 'development' then 'dev'
          else ''
          end

    result = ActiveFedora.fedora.connection.get(url).body
    triples = ::RDF::Reader.for(:ttl).new(result)
    rdf = ::RDF::Graph.new << triples
    rdf.query(predicate: ::RDF::Vocab::LDP.contains).count
  end

  def number_of_objects_in_solr
    q = Blacklight.default_index.connection.get 'select', q: "has_model_ssim:'info:fedora*'"
    q['response']['numFound']
  end

  desc 'update the index on all GenericWorks'
  task update_generic_work_index: :environment do
    GenericWork.all.each(&:update_index)
  end

  desc 'update the index on all GenericWorks that are contained by collections'
  task update_collection_generic_file_index: :environment do
    Collection.all.each do |col|
      puts "updating collection #{col.id}"
      begin
        col.members.each(&:update_index)
      rescue
        puts "\n\n Error updating #{col.id}"
      end
    end
  end
end
