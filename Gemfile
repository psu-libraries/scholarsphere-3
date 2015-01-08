source 'https://rubygems.org'

# Ruby on Rails components
gem 'rails', '4.1.7'
gem 'mysql2', '0.3.16'

# Hydra community components
# TODO: Point this back at a released version once this branch is merged
gem 'sufia', github: 'projecthydra/sufia', branch: 'concernize_collections_controller'
gem 'hydra-batch-edit', '1.1.1'
gem 'hydra-ldap', '0.1.0'
gem 'hydra-derivatives', '1.0.0.rc1'
gem 'browse-everything', github: 'projecthydra-labs/browse-everything', ref: 'd380e4b8c91'

# Other components
gem 'clamav'
gem 'coffee-rails'
gem 'devise', '~> 3.2.2'
gem 'jquery-rails'
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype', ref: '384fcb5d11b6'
gem 'nest'
gem 'newrelic_rpm'
gem 'rainbow'
gem 'resque-pool'
gem 'sass'
gem 'sass-rails', '~> 4.0.3'
gem 'select2-rails'
gem 'sitemap'
gem 'therubyracer'
gem 'uglifier'
gem 'whenever'
gem 'yaml_db'

group :development, :test do
  gem 'byebug', require: false
  gem 'capybara', '~> 2.0'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'equivalent-xml'
  gem 'factory_girl_rails', '~> 4.1.0'
  gem 'fuubar'
  gem 'jettywrapper'
  gem 'launchy'
  gem 'poltergeist'
  gem 'rspec-activemodel-mocks'
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
  gem 'passenger'
  gem 'unicorn-rails'
end

group :test do
  gem 'vcr'
  gem 'webmock'
end
