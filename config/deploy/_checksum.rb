namespace :checksum do
  desc "run rake task to generate missing checksums"
  task :all, roles: :db  do
    run <<-CMD.compact
    cd -- #{latest_release} &&
    RAILS_ENV=#{rails_env.to_s.shellescape} #{rake} #{application}:checksum:all
    CMD
  end
end