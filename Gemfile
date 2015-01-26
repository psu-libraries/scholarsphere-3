source 'https://rubygems.org'

# Ruby on Rails components
gem 'rails', '4.1.9'
gem 'mysql2', '~> 0.3.17'

# Hydra community components
gem 'sufia', github: 'projecthydra/sufia', ref: 'c50c4cc'
gem 'hydra-editor', github: 'projecthydra-labs/hydra-editor', ref: 'c9718ae'
gem 'hydra-ldap', '0.1.0'
gem 'fedora-migrate', github: 'projecthydra-labs/fedora-migrate', ref: '75076ea6602f9505b508202eb42759d9949b5d66'

# Other components
gem 'clamav'
gem 'coffee-rails'
gem 'devise', '~> 3.4'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype', ref: '384fcb5d11b6'
gem 'nest'
gem 'newrelic_rpm'
gem 'rainbow'
gem 'resque-pool'
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
  gem 'factory_girl_rails', '~> 4.1'
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
