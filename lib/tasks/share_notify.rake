namespace :share do

  desc "Push all available GenericFiles to SHARE Notify"
  task files: :environment do
    shareable_files.each do |file|
      puts "Sending #{file.id} to SHARE Notify"
      Sufia.queue.push(ShareNotifyJob.new(file.id))
    end
  end 

  def shareable_files
    ShareNotifyFilteredList.new(
      ResourceFilteredList.new(
        PublicFilteredList.new(GenericFile.all).filter
      ).filter
    ).filter
  end

end
