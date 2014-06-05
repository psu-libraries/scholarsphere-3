source 'https://rubygems.org'

# Ruby on Rails components
gem 'rails', '4.0.5'
gem 'mysql2', '0.3.14'

# Hydra community components
#gem 'sufia', '4.0.0.beta2'
gem 'sufia', github: 'projecthydra/sufia', branch:'master', ref:'7048ae43b8ce3ec58b34418eb436020c7ee2c0f8'
gem 'hydra-batch-edit', '1.1.1'
gem 'hydra-editor', '0.1.1'
gem 'hydra-collections', '2.0.0'
gem 'hydra-derivatives', '0.0.7'
gem 'hydra-ldap', '0.1.0'

# Other components
gem 'rainbow', '1.1.4'
gem 'jquery-rails', '2.1.4'
gem 'resque-pool', '0.3.0'
gem 'devise','3.2.2'
gem 'nest', '1.1.1'
gem 'sitemap', '0.3.3'
gem 'yaml_db', '0.2.3'
gem 'clamav', '0.4.1'
gem 'therubyracer', '0.12.0'
gem 'select2-rails', '3.4.2'
gem 'whenever', '0.8.4'
gem 'newrelic_rpm', '3.7.0.177'
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype', ref: '384fcb5d11b6'

group :assets do
  gem 'sass-rails', '4.0.3'
  gem 'coffee-rails', '4.0.1'
  gem 'uglifier', '2.3.2'
end

group :development, :test do
  gem 'fuubar'
  gem 'sqlite3'
  gem 'poltergeist'
  gem 'rspec-rails', '2.14.0'
  gem 'capybara', '2.2.0'
  gem 'jettywrapper'
  gem 'factory_girl_rails', '~> 4.1.0'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'equivalent-xml', '0.4.0'
end

group :development do
  gem 'debugger'
  gem 'unicorn-rails'
  gem 'capistrano', '2.15.5'
  gem 'capistrano-rbenv', '1.0.5'
  gem 'capistrano-ext', '1.2.1'
  gem 'capistrano-notification', '0.1.1'
end
