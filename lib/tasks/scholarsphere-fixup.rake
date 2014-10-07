namespace :scholarsphere do

  namespace :fixup do

    desc "Update a user's batches by USER="
    task user_batch: :environment do
      raise "Must specify a user.  Ex:  USER='user123" unless ENV['USER']
      u = User.where(login:ENV['USER']).first
      batch_messages = u.mailbox.inbox.reject { |msg| msg.last_message.subject != "Batch upload complete"}
      batch_messages.each do |msg|
        body = msg.last_message.body
        batch_id =  body.gsub(/<span id="ss-([0-9a-z]{9})".*/) {|match| "scholarsphere:#{$1}"}
        batch = Batch.find(batch_id) rescue next
        puts "processing #{batch_id}..."
        gfs = []
        body.gsub(/<a href=["']\/files\/([0-9a-zA-Z]{9})/) {|match| gfs << "scholarsphere:#{$1}"}
        gfs.each do |id|
          f = GenericFile.find(id) rescue next
          f.update_index
          batch.generic_files << f unless  batch.generic_files.include? f
        end
        batch.save
      end
    end

  end
end
