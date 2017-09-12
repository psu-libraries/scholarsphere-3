# frozen_string_literal: true

namespace :scholarsphere do
  namespace :migrate_titles do
    desc 'Display what titles will migrate'
    task dry_run: :environment do
      works_with_multiple_titles.each do |work|
        puts "#{work['id']} title: #{work['title_tesim'].first} sub title: #{work['title_tesim'][1..-1].join('; ')}"
      end
    end

    task run: :environment do
      works_with_multiple_titles.each do |solr_work|
        puts "converting #{solr_work['id']}"
        work = GenericWork.find(solr_work['id'])
        all_titles = work.title.clone
        work.title = [all_titles.first]
        work.subtitle = all_titles[1..-1].join('; ')
        work.save
      end
    end

    def works_with_multiple_titles
      resp = ActiveFedora::SolrService.instance.conn.get 'select',
                                                         params: { fl: ['id', 'title_tesim'], rows: 10000,
                                                                   fq: 'has_model_ssim: GenericWork', q: '' }
      puts "found doucments #{resp['response']['docs'].count}"
      resp['response']['docs'].select { |doc| doc['title_tesim'].count > 1 }
    end
  end
end
