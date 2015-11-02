source 'https://rubygems.org'

# Ruby on Rails components
gem 'rails', '4.2.2'
gem 'mysql2', '~> 0.3.17' unless ENV['CI']

# Hydra community components
#gem 'active-fedora', '9.4.0'
gem 'browse-everything', github: 'projecthydra-labs/browse-everything', ref: 'e7c83be25'
gem 'fedora-migrate', github: 'projecthydra-labs/fedora-migrate', ref: '85dd700df3b3195bceea6b988ec70bb2b82bd282'
gem 'hydra-derivatives', '1.1.0'
gem 'hydra-head', github: 'projecthydra/hydra-head', ref: '84b4406c0f369dc2562e06a981b7ea925ceab814'
gem 'hydra-ldap', '0.1.0'
gem 'sufia', github: 'projecthydra/sufia', ref: '74397e40043cc1a30aa4782eb9e82932cbbedef4'

# Other components
gem 'clamav' unless ENV['TRAVIS'] == 'true'
gem 'coffee-rails'
gem 'devise', '~> 3.4'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails', '~> 3.1'
gem 'kaminari', github: 'jcoyne/kaminari', branch: 'sufia'
gem 'namae', '0.9.3'
gem 'nest'
gem 'newrelic_rpm'
gem 'rack-maintenance'
gem 'rainbow'
gem 'resque-pool'
gem 'rsolr'
gem 'sass-rails'
gem 'select2-rails'
gem 'sitemap'
gem 'therubyracer'
gem 'uglifier'
gem 'whenever'
gem 'yaml_db'

group :development, :test do
  gem 'jettywrapper'
  gem 'rspec-its'
  gem 'rspec-rails'
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
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'unicorn-rails'
end

group :test do
  gem 'capybara', '~> 2.0'
  gem 'database_cleaner'
  gem 'equivalent-xml'
  gem 'factory_girl_rails', '~> 4.1'
  gem 'fuubar'
  gem 'poltergeist'
  gem 'rspec-activemodel-mocks'
  gem 'vcr'
  gem 'webmock'
end

group :debug do
  gem 'byebug', require: false
  gem 'capybara-screenshot'
  gem 'launchy'
end
