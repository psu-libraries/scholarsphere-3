require 'jettywrapper'
Jettywrapper.hydra_jetty_version = "v8.1.1"

namespace :jetty do
  desc "Apply all Solr and Fedora configs to Jetty, including full-texting searching"
  task :config do
    Rake::Task["sufia:jetty:download_jars"].invoke
    Rake::Task["hydra:jetty:config"].invoke
  end
end
