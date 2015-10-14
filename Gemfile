source 'https://rubygems.org'

# Ruby on Rails components
gem 'rails', '4.2.2'
gem 'mysql2', '~> 0.3.17' unless ENV['CI']

# Hydra community components
gem 'hydra-ldap', '0.1.0'
gem 'hydra-derivatives', '1.1.0'
gem 'fedora-migrate', github: 'projecthydra-labs/fedora-migrate', ref: '85dd700df3b3195bceea6b988ec70bb2b82bd282'
gem 'sufia', github: 'projecthydra/sufia', ref: 'fa0190067b'
gem 'browse-everything', github: 'projecthydra-labs/browse-everything', ref: 'e7c83be25'
gem 'active-fedora', '9.4.0'
gem 'hydra-head', '9.2.2'

# Other components
gem 'clamav' unless ENV['TRAVIS'] == 'true'
gem 'coffee-rails'
gem 'devise', '~> 3.4'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails', '~> 3.1'
gem 'kaminari', github: 'jcoyne/kaminari', branch: 'sufia'
gem 'nest'
gem 'newrelic_rpm'
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
gem 'rack-maintenance'
gem 'namae', '0.9.3'

group :development, :test do
  gem 'jettywrapper'
  gem 'rspec-rails'
  gem 'sqlite3'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano', '~> 3.0', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rbenv', '~> 2.0', require: false
  gem 'capistrano-passenger'
  gem 'capistrano-resque', '~> 0.2.1', require: false
  gem 'capistrano-rbenv-install'
 # gem 'passenger'
  gem 'unicorn-rails'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :test do
  gem 'database_cleaner'
  gem 'equivalent-xml'
  gem 'factory_girl_rails', '~> 4.1'
  gem 'fuubar'
  gem 'poltergeist'
  gem 'vcr'
  gem 'webmock'
  gem 'capybara', '~> 2.0'
  gem 'rspec-activemodel-mocks'
end

group :debug do
  gem 'launchy'
  gem 'capybara-screenshot'
  gem 'byebug', require: false
end
