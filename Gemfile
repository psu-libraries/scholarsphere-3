# frozen_string_literal: true

source 'https://rubygems.org'

# Ruby on Rails components
gem 'rails', '4.2.7.1'
gem 'mysql2', '~> 0.3.17' unless ENV['CI']

# Hydra gems
gem 'active-fedora', '~> 11.5'
gem 'sufia', '7.4.1'
gem 'blacklight_advanced_search', '~> 6.0'

# Use patched version of mail. Remove this once 2.6.6 is officially out
gem 'mail', '= 2.6.6.rc1'

# Other components
gem 'bootsnap', require: false
gem 'clamav' unless ENV['TRAVIS'] == 'true'
gem 'coderay'
gem 'coffee-rails'
gem 'devise', '~> 4.2'
gem 'ezid-client'
gem 'figaro'
gem 'jbuilder', '~> 2.6'
gem 'jquery-rails', '~> 4.2'
gem 'kaminari_route_prefix'
gem 'namae', '~> 1.0'
gem 'nest'
gem 'newrelic_rpm'
gem 'psu_dir'
gem 'rack-maintenance'
gem 'rainbow'
gem 'rdf'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'redcarpet'
gem 'resque-pool'
gem 'rsolr'
gem 'rubyzip'
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
  gem 'capybara-screenshot'
  gem 'coveralls', require: false
  gem 'faker'
  gem 'fcrepo_wrapper'
  gem 'niftany'
  gem 'rspec'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'solr_wrapper'
  gem 'sqlite3'
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

  gem 'travis', require: false
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
