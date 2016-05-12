source 'https://rubygems.org'

# Ruby on Rails components
gem 'rails', '4.2.6'
gem 'mysql2', '~> 0.3.17' unless ENV['CI']

# Hydra community components
gem 'browse-everything', '~> 0.10'
gem 'hydra-ldap', '0.1.0'
gem 'sufia', github: 'projecthydra/sufia', branch: 'master'

# Other components
gem 'clamav' unless ENV['TRAVIS'] == 'true'
gem 'coffee-rails'
gem 'devise', '~> 3.5'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails', '~> 3.1'
gem 'kaminari_route_prefix'
gem 'ldap_disambiguate'
gem 'namae', '0.9.3'
gem 'nest'
gem 'newrelic_rpm'
gem 'rack-maintenance'
gem 'rainbow'
gem 'resque-pool'
gem 'rsolr'
gem 'sass-rails'
gem 'select2-rails'
gem 'share_notify'
gem 'sitemap'
gem 'sprockets-rails'
gem 'therubyracer'
gem 'turbolinks'
gem 'uglifier'
gem 'whenever'
gem 'yaml_db'

group :development, :test do
  gem 'fcrepo_wrapper'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'rubocop', '~> 0.39.0'
  gem 'rubocop-rspec', '~> 1.4.1'
  gem 'solr_wrapper'
  gem 'sqlite3'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano', '~> 3.0', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-rbenv', '~> 2.0', require: false
  gem 'capistrano-rbenv-install'
  gem 'capistrano-resque', '~> 0.2.1', require: false
  gem 'unicorn-rails'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'equivalent-xml'
  gem 'factory_girl_rails', '~> 4.1'
  gem 'fuubar'
  gem 'poltergeist', '~> 1.9'
  gem 'rspec-activemodel-mocks'
  gem 'vcr'
  gem 'webmock'
end

group :debug do
  gem 'byebug', require: false
  gem 'capybara-screenshot'
  gem 'launchy'
end
