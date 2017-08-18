# frozen_string_literal: true

namespace :scholarsphere do
  namespace :analytic do
    desc 'Load data from a file of format # dd/mmm/yyyy /downloads/<id> and stores the appropriate record for each file line in the file_downloads table'
    task :load, [:filename] => :environment  do |_t, args|
      File.open(args[:filename]).each(sep: "\n") do |line|
        next if line.strip.empty?
        parts = line.split
        count = parts[0].to_i
        date = Date.parse(parts[1])
        id = parts[2].split(/\//).last
        next if id == 'downloads'
        id = "scholarsphere:#{id.split('?').first}"
        stat = FileDownloadStat.where(date: date, file_id: id).first
        if stat.blank?
          file = begin
                   GenericFile.load_instance_from_solr(id)
                 rescue
                   next
                 end
          user = User.where(login: file.depositor).first
          if user.nil?
            user = User.create(login: file.depositor, email: file.depositor)
            user.populate_attributes
          end

          FileDownloadStat.create(date: date, downloads: count, file_id: id, user_id: user.id)
        elsif stat.downloads < count
          puts 'Updating count'
          stat.downloads = count
          stat.save
        end
      end
    end
  end
end
