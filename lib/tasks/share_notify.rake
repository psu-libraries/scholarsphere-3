namespace :share do

  desc "Push all available GenericFiles to SHARE Notify"
  task files: :environment do
    shareable_files.each do |file|
      puts "Sending #{file.id} to SHARE Notify"
      ShareNotifyJob.perform_later(file)
    end
  end 

  def shareable_files
    ResourceFilteredList.new(
      PublicFilteredList.new(GenericWork.where(read_access_group_ssim: ["public"])).filter
    ).filter
  end

end
