# workaround for "invalid byte sequence in US-ASCII (ArgumentError)" breaking the Jenkins build
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'http://rubygems.org'

# Ruby on Rails components
gem 'rails', '4.0.2'
gem 'mysql2', '0.3.11'

# Hydra community components
gem 'sufia', github:"projecthydra/sufia"
gem 'hydra-batch-edit'
gem 'hydra-editor' # Currently using this for its edit view partials (used when editing collections)
gem 'hydra-collections'#, github:'psu-stewardship/hydra-collections', ref:'d475e4134533a0c7d'
gem 'hydra-ldap', '0.1.0'
gem 'jquery-rails', '2.1.4'
gem 'resque-pool', '0.3.0'
gem 'rmagick', '2.13.2', :require => 'RMagick' # :require arg is necessary on Linux-based hosts
gem 'devise'
gem 'daemons', '1.1.9'
gem 'zipruby', '0.3.6'
gem 'nest', '1.1.1'
gem 'sitemap', '0.3.3'
gem 'yaml_db', '0.2.3'
gem 'clamav', '0.4.1'
gem 'equivalent-xml', '0.3.0'
gem 'therubyracer', '0.10.2'
gem 'bootstrap-sass', '2.2.2.0'
gem 'font-awesome-sass-rails', '3.0.2.2'
gem 'unicode', :platforms => [:mri_18, :mri_19]
gem 'select2-rails', '3.4.2' # for transfer ownership javascript
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'


# crontab it up
gem 'whenever'

# rake needs rspec and cucumber in all environments
gem 'rspec'
gem 'cucumber'

group :assets do
  gem 'sass-rails', '4.0.1'
  gem 'coffee-rails', '4.0.1'
  gem 'uglifier', '2.3.2'
end

group :development, :test do
  gem 'sqlite3'
  gem 'unicorn-rails'
  gem 'debugger'
  gem 'selenium-webdriver', '~> 2.35.0'
  gem 'rubyzip', '< 1.0.0' 
  gem 'headless'
  gem 'rspec-rails', '>= 2.11.0'
  gem 'mocha', '0.13.3', :require => false
  gem 'cucumber-rails', '~> 1.0', :require => false
  gem 'capybara', '~>1.1.3'
  gem 'jettywrapper'
  gem 'factory_girl_rails', '~> 4.1.0'
  gem 'launchy'
  gem 'database_cleaner'
  # capistrano deployments
  gem 'capistrano', '2.15.5'
  gem 'capistrano-rbenv', '1.0.5'
  gem 'capistrano-ext', '1.2.1'
  gem 'capistrano-notification', '0.1.1'
end

