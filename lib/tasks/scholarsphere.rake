require 'action_view'
require 'rainbow'

include ActionView::Helpers::NumberHelper

namespace :scholarsphere do
  # adding a logger since it got removed from our gemset
  def logger
    Rails.logger
  end

  def file_fq
    "#{Solrizer.solr_name('has_model', :symbol)}:FileSet"
  end

  def work_fq
    "#{Solrizer.solr_name('has_model', :symbol)}:GenericWork"
  end

  def file_set_id_list( model_filter = file_fq, query = '')
    resp = ActiveFedora::SolrService.instance.conn.get "select",
                                                       params: { fl: ['id'],
                                                                 fq: model_filter,
                                                                 q:  query }
    puts resp
    # get the totalNumber and the size of the current response
    total_num = resp["response"]["numFound"]
    id_list = resp["response"]["docs"]
    page = 1

    # loop through each page appending the ids to the original list
    while id_list.length < total_num
      page += 1
      resp = ActiveFedora::SolrService.instance.conn.get "select",
                                                         params: { fl: ['id'],
                                                                   fq: file_fq,
                                                                   page: page,
                                                                   q:  query }
      id_list += resp["response"]["docs"]
      total_num = resp["response"]["numFound"]
    end
    id_list.map{|o| o["id"]}
  end

  def process_file_set_id_list(id_list, &block)
    id_list.each do |id|
      file_set = FileSet.find(id)
      block.call file_set
    end
  end

  desc "(Re-)Generate the secret token"
  task generate_secret: :environment do
    File.open("#{Rails.root}/config/initializers/secret_token.rb", 'w') do |f|
      f.puts "#{Rails.application.class.parent_name}::Application.config.secret_key_base = '#{SecureRandom.hex(64)}'"
    end
  end

  desc "Re-solrize all objects"
  task resolrize: :environment do
    ResolrizeJob.perform_later
  end

  desc "Re-solrize top level objects"
  task resolrize_top: :environment do
    resource = Ldp::Resource::RdfSource.new(ActiveFedora.fedora.connection, ActiveFedora::Base.id_to_uri(''))
    # GET could be slow if it's a big resource, we're using HEAD to avoid this problem,
    # but this causes more requests to Fedora.
    return [] unless Ldp::Response.rdf_source?(resource.head)
    immediate_descendant_uris = resource.graph.query(predicate: ::RDF::Vocab::LDP.contains).map { |descendant| descendant.object.to_s }
    immediate_descendant_uris.each do |uri|
      id = ActiveFedora::Base.uri_to_id(uri)
      puts "Re-index everything ... #{id}"
      ActiveFedora::Base.find(id).update_index if (id.length == 9)
    end
  end

  desc 'copy fits configuration files into the fits submodule'
  task :fits_conf do
    puts 'copying fits config files'
    out = `cp fits_conf/* fits/xml`
  end

  namespace :export do
    desc "Dump metadata as RDF/XML for e.g. Summon integration"
    task rdfxml: :environment do
      raise "rake scholarsphere:export:rdfxml output=FILE" unless ENV['output']
      export_file = ENV['output']
      triples = RDF::Repository.new
      rows = FileSet.count
      FileSet.find(:all).each do |file_set|
        next unless file_set.public?
        # TODO how do I get tripples for a file_set.  Should I include the work metadata
        RDF::Reader.for(:ntriples).new(file_set.descMetadata.content) do |reader|
          reader.each_statement do |statement|
            triples << statement
          end
        end
      end
      unless triples.empty?
        RDF::Writer.for(:rdfxml).open(export_file) do |writer|
          writer << triples
        end
      end
    end
  end

  namespace "checksum" do
    desc "Validate checksum on all the FileSets"
    task "all"  => :environment do
      errors = []
      process_file_set_id_list(file_set_id_list) do |file_set|
        md5 = Digest::MD5.new
        md5 << file_set.original_file.content
        if md5.hexdigest != file_set.original_file.original_checksum.first
          errors << file_set
        end
      end
      errors.each { |file_set| puts "Invalid Checksum: #{file_set.id} " }
    end
  end

  desc "Convert Resource Type"
  task "master_thesis" => :environment do

    file_set_id_list(work_fq, "#{Solrizer.solr_name('resource_type')}:\"Masters Thesis\"").each do |id|
      work = GenericWork.find(id)
      puts "Work Found #{work.title} #{work.resource_type}"
      resources = work.resource_type
      work.resource_type = resources.map { |type| type == "Masters Thesis" ? "Thesis" : type }
      puts "Work Updated #{work.title} #{work.resource_type}"
      work.save
    end
  end

  # Start date must be in format 'yyyy/MM/dd'
  desc "Prints to stdout a list of failed jobs in resque"
  task "get_failed_jobs", [:start_date, :details] => :environment do |_cmd, args|
    #todo Not sure we can do this with the new Active Job based records
    details = (args[:details] == "true")
    start_date = args[:start_date] || Date.today.to_s.tr('-', '/')
    log = ""
    i = 0
    puts "Getting failed jobs from: #{start_date}"
    Resque::Failure.each do |i, job|
      i += 1
      job_failed_at = job["failed_at"]
      if job_failed_at >= start_date
        payload = job["payload"]
        job_args64 = payload["args"]
        job_args = Base64.decode64(job_args64[0])
        prefix_at = job_args.index("scholarsphere:")
        if prefix_at.nil?
          log += "Unexpected job arguments found: #{job_args}\r\n"
        else
          sufix_at = job_args.index(":", prefix_at + 14)
          pid = job_args[prefix_at, sufix_at - prefix_at - 1].chomp
          if details

            exception = job["exception"]
            error = job["error"]
            backtrace = job["backtrace"][0]
            log += "PID: #{pid}\r\n"
            log += "Failed at: #{job_failed_at}\r\n"
            log += "Exception: #{exception} - #{error}\r\n"
            log += "Backtrace: #{backtrace}\r\n"
            begin
              gf = GenericFile.find(pid)
              log += "File name: #{gf[:filename]}\r\n"
              log += "Mime type: #{gf[:mime_type]}\r\n"
            rescue Exception => e
              log += "File name: (could not be determined)\r\n"
            end
            log += "---------------\r\n"
          else
            log += "#{pid}\r\n"
          end
        end
        puts i if (i % 100) == 0
      end
    end

    puts "Writting log..."
    File.write('find_failed_jobs.log', log)
    puts "Done."
  end

  def id_list_from_file(file_name)
    abort "Must provide a file name to read the PIDs" if file_name.nil?
    puts "Processing file #{file_name}"
    id_list = []
    File.readlines(file_name).each do |line|
      pid = line.chomp
      id_list << pid unless pid.empty?
    end
    id_list
  end

  desc "Queues a job to (re)generate the sitemap.xml"
  task "sitemap_queue_generate" => :environment do
    SitemapRegenerateJob.perform_later
  end

  desc "generate and mail the stats report for yesterday"
  task "deliver_stats" => :environment do
    UserMailer.stats_email(1.day.ago.beginning_of_day, 1.day.ago.end_of_day).deliver
  end
  desc "generate and mail the stats report for the past week"
  task "deliver_weekly_stats" => :environment do
    UserMailer.stats_email(8.day.ago.beginning_of_day, 1.day.ago.end_of_day).deliver
  end

  desc "Mark a work as private"
  task "make_private", [:work_id] => :environment do |_cmd, args|
    work_id = args[:work_id]
    abort "Must provide a work id to mark as private" if work_id.nil?
    work = GenericWork.find(work_id)
    work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    work.file_sets.each do |file_set|
      file_set.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      file_set.save
    end
    result = work.save
    puts "Work #{work_id} marked as private: #{result}"
  end
end
