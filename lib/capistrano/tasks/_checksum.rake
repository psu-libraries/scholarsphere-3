namespace :checksum do
  desc "run rake task to generate missing checksums"
  task :all do
   on roles(:db)  do
    within release_path do
     execute :rake,"#{fetch(:application)}:checksum:all","RAILS_ENV=production"
    #execute "cd -- #{current_path}"
    #execute "RAILS_ENV = #{fetch(:rails_env).to_s.shellescape} #{rake} #{fetch(:application)}:checksum:all"
    
    #execute << EOF "cd -- #{fetch(:latest_release)} &&                    RAILS_ENV = #{     
    #run <<-CMD.compact
    #cd -- #{latest_release} &&
    #RAILS_ENV=#{rails_env.to_s.shellescape} #{rake} #{application}:checksum:all
    #CMD
   end
  end
 end
end
