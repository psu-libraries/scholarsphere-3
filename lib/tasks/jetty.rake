require 'jettywrapper'
if ENV['MIGRATE']
  Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/fedora-4/migrate.zip"
end

namespace :scholarsphere do
  namespace :jetty do
    desc "Apply all Solr and Fedora configs to Jetty, including full-texting searching"
    task :config do
      Rake::Task["sufia:jetty:download_jars"].invoke
      Rake::Task["hydra:jetty:config_solr"].invoke
    end
  end
end
