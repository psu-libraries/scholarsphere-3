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
gem 'sufia', github:"projecthydra/sufia", :ref => '3bbe2e8b549756a98fb3e3dda7a715516b4ad709'
gem 'hydra-batch-edit'
gem 'hydra-editor' # Currently using this for its edit view partials (used when editing collections)
gem 'hydra-collections', github:"projecthydra/hydra-collections"
#gem 'hydra-collections'
gem 'hydra-ldap', '0.1.0'
gem 'jquery-rails', '2.1.4'
gem 'resque-pool', '0.3.0'
gem 'devise'
gem 'nest', '1.1.1'
gem 'sitemap', '0.3.3'
gem 'yaml_db', '0.2.3'
gem 'clamav', '0.4.1'
gem 'equivalent-xml', '0.3.0'
gem 'therubyracer', '0.12.0'
gem 'bootstrap-sass', '2.2.2.0'
gem 'font-awesome-sass-rails', '3.0.2.2'
gem 'unicode', :platforms => [:mri_18, :mri_19]
gem 'select2-rails', '3.4.2' # for transfer ownership javascript
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'

gem 'rspec'     # capistrano needs rake. rake needs rspec and cucumber.
gem 'cucumber'  # capistrano needs rake. rake needs rspec and cucumber.

# crontab it up
gem 'whenever'

group :assets do
  gem 'sass-rails', '4.0.1'
  gem 'coffee-rails', '4.0.1'
  gem 'uglifier', '2.3.2'
end

group :development, :test do
  gem 'sqlite3'
  gem 'selenium-webdriver', '~> 2.35.0'
  gem 'rubyzip', '< 1.0.0' 
  gem 'headless'
  gem 'rspec-rails', '>= 2.11.0'
  gem 'cucumber-rails', '~> 1.0', :require => false
  gem 'capybara', '~>1.1.3'
  gem 'jettywrapper'
  gem 'factory_girl_rails', '~> 4.1.0'
  gem 'launchy'
  gem 'database_cleaner'
end

group :development do
  gem 'unicorn-rails'
  # capistrano deployments
  gem 'capistrano', '2.15.5'
  gem 'capistrano-rbenv', '1.0.5'
  gem 'capistrano-ext', '1.2.1'
  gem 'capistrano-notification', '0.1.1'
end

