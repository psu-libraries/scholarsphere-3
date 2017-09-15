# frozen_string_literal: true

source 'https://rubygems.org'

# Ruby on Rails components
gem 'rails', '4.2.7.1'
gem 'mysql2', '~> 0.3.17' unless ENV['CI']

# Hydra gems
gem 'active-fedora', '~> 10.3.0.rc2'
gem 'sufia', github: 'projecthydra/sufia', branch: '7.2-migration'
gem 'flipflop', git: 'https://github.com/jcoyne/flipflop.git', branch: 'hydra'
gem 'curation_concerns', github: 'projecthydra/curation_concerns', ref: 'b073550'
gem 'hydra-works', github: 'projecthydra/hydra-works', ref: 'f948eb0'

# Use patched version of mail. Remove this once 2.6.6 is officially out
gem 'mail', '= 2.6.6.rc1'

# Other components
gem 'clamav' unless ENV['TRAVIS'] == 'true'
gem 'coffee-rails'
gem 'devise', '~> 4.2'
gem 'figaro'
gem 'jbuilder', '~> 2.6'
gem 'jquery-rails', '~> 4.2'
gem 'kaminari_route_prefix'
gem 'ldap_disambiguate'
gem 'namae', '0.9.3'
gem 'nest'
gem 'newrelic_rpm'
gem 'rack-maintenance'
gem 'rainbow'
gem 'rdf', '~> 1.99'
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
  gem 'coveralls', require: false
  gem 'fcrepo_wrapper'
  gem 'faker'
  gem 'rspec'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'solr_wrapper'
  gem 'sqlite3'
  gem 'capybara-screenshot'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'

  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.7', require: false
  gem 'capistrano-bundler', '~> 1.2', require: false
  gem 'capistrano-rails', '~> 1.2', require: false
  gem 'capistrano-rbenv', '~> 2.1', require: false
  gem 'capistrano-rbenv-install'
  gem 'capistrano-resque', '~> 0.2.1', require: false

  gem 'unicorn-rails'
  gem 'xray-rails'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'equivalent-xml'
  gem 'factory_girl_rails', '~> 4.1'
  gem 'poltergeist', '~> 1.9'
  gem 'rspec-activemodel-mocks'
  gem 'selenium-webdriver'
  gem 'vcr'
  gem 'webmock'
end

group :debug do
  gem 'byebug', require: false
  gem 'launchy'
end
