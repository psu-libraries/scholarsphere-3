# frozen_string_literal: true

namespace :scholarsphere do
  namespace :fixup do
    desc "Update a user's batches by USER="
    task user_batch: :environment do
      raise "Must specify a user.  Ex:  USER='user123" unless ENV['USER']
      u = User.where(login: ENV['USER']).first
      batch_messages = u.mailbox.inbox.select { |msg| msg.last_message.subject == 'Batch upload complete' }
      batch_messages.each do |msg|
        body = msg.last_message.body
        batch_id = body.gsub(/<span id="ss-([0-9a-z]{9})".*/) { |_match| "scholarsphere:#{$1}" }
        batch = begin
                  Batch.find(batch_id)
                rescue
                  next
                end
        puts "processing #{batch_id}..."
        gfs = []
        body.gsub(/<a href=["']\/files\/([0-9a-zA-Z]{9})/) { |_match| gfs << "scholarsphere:#{$1}" }
        gfs.each do |id|
          next if batch.generic_file_ids.include? id
          f = begin
                GenericFile.find(id)
              rescue
                next
              end
          f.update_index
          batch.generic_file_ids << id
        end
        batch.save
      end
    end

    desc 'Update date uploaded to be a date class instead of a string'
    task update_upload_date: :environment do
      total_num = GenericFile.all.count
      resp = ActiveFedora::SolrService.instance.conn.get 'select',
                    params: { fl: ['id', 'date_uploaded_ssi'], fq: "#{Solrizer.solr_name('has_model', :symbol)}:GenericFile", rows: total_num }
      id_list = resp['response']['docs']

      id_list.each do |id_obj|
        # date_uploaded_ssi only gets created when the date is stored as a string.  If it is properly stored as a date the field is date_uploaded_dtsi
        if id_obj['date_uploaded_ssi'].present?
          gf = GenericFile.find(id_obj['id'])
          gf.date_uploaded = DateTime.parse(gf.date_uploaded)
          gf.save
        end
      end
    end
  end
end
