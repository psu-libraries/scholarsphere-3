# frozen_string_literal: true

namespace :scholarsphere do
  namespace :users do
    include ActionView::Helpers::NumberHelper

    desc "list user's email"
    task list: :environment do
      users = User.all.map(&:email).reject(&:blank?)
      f = File.new('user_emails.txt', 'w')
      f.write(users.join(', '))
      f.close
    end

    # Populates the User table with users who have deposited content in to Scholarsphere but
    # for one reason or another do not have their records in the database. As an extra
    # measure, the records of existing users also have their attributes re-populated.
    desc 'Restore missing user accounts'
    task restore: :environment do
      depositor_logins.each { |l| User.create(login: l).populate_attributes if User.find_by(login: l).nil? }
      User.all.each do |u|
        next if depositor_logins.include? u.login

        u.populate_attributes
      end
    end

    desc 'Report users quota in SS'
    task quota_report: :environment do
      # caution_sz = 3_000_000_000   # 3GB
      # warning_sz = 5_000_000_000   # 5GB
      # problem_sz = 10_000_000_000  # 10GB
      # loop over users in active record
      users = {}
      User.all.each do |u|
        # for each user query get list of documents
        user_files = FileSet.where(depositor: u.login)
        # sum the size of the users docs
        sz = 0
        user_files.each do |f|
          # puts number_to_human_size(f.file_size.first.to_i)
          sz += f.file_size.first.to_i
          # puts "#{sz}:#{f.file_size.first}"
        end
        uname = "#{u.login} #{u.name}"
        users = users.merge(uname => sz)
      end
      longest_key = users.keys.max_by(&:length)
      printf "%-#{longest_key.length}s %s", 'User', 'Space Used'
      puts ''
      users = users.sort_by { |_key, value| value }.to_h
      users.each_pair do |k, v|
        printf "%-#{longest_key.length}s %s", k, number_to_human_size(v)
        puts ''
      end
    end

    def depositor_logins
      @depositor_logins ||= ActiveFedora::SolrService.query('depositor_ssim:[* TO *]', fl: ['depositor_ssim'], rows: 10000000)
        .map { |hit| hit.fetch('depositor_ssim').first }
        .uniq
    end
  end
end
