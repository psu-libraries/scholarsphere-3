namespace :jetty do
  desc "Apply all configs to Testing Server (relies on hydra:jetty:config tasks unless you override it)"
  task :config do
    Rake::Task["hydra:jetty:config"].invoke
    Rake::Task["scholarsphere:jetty:config"].invoke
  end
end

namespace :scholarsphere do

  namespace :jetty do
    desc "Copies the contents of solr_conf into the Solr development-core and test-core of Testing Server"
    task :config do
        FileList['solr_conf/lib/*'].each do |f|
          cp_r("#{f}", 'jetty/solr/lib/contrib/', verbose: true)
        end
    end
  end
end
