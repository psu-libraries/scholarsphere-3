# workaround for "invalid byte sequence in US-ASCII (ArgumentError)" breaking the Jenkins build
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'http://rubygems.org'

# Ruby on Rails components
gem 'rails', '3.2.13'
gem 'rack', '1.4.5'
gem 'mysql2', '0.3.11'

# Hydra community components
gem 'sufia', :github => 'projecthydra/sufia', :ref => '9f37753677ca98fcf0422d47f01e35b582f21e53'
gem 'hydra-collections', :github => 'psu-stewardship/hydra-collections', :ref => 'eca169de446db282376ffdee9bf8358a8baf9793'
gem 'hydra-batch-edit', '0.3.1'
gem 'hydra-ldap', '0.1.0'
gem 'jquery-rails', '2.1.4'
gem 'resque-pool', '0.3.0'
gem 'rmagick', '2.13.2', :require => 'RMagick' # :require arg is necessary on Linux-based hosts
gem 'devise', '2.2.3'
gem 'paperclip', '3.3.0'
gem 'daemons', '1.1.9'
gem 'zipruby', '0.3.6'
gem 'rails_autolink', '1.0.9'
gem 'acts_as_follower', '0.1.1'
gem 'nest', '1.1.1'
gem 'sitemap', '0.3.3'
gem 'yaml_db', '0.2.3'
gem 'mailboxer', '0.8.0'
gem 'mail_form', '1.4.1'
gem 'clamav', '0.4.1'
gem 'equivalent-xml', '0.3.0'
gem 'execjs', '1.4.0'
gem 'therubyracer', '0.10.2'
gem 'bootstrap-sass', '2.2.2.0'
gem 'font-awesome-sass-rails', '3.0.2.2'
gem 'unicode', :platforms => [:mri_18, :mri_19]
gem 'select2-rails', '3.3.1' # for transfer ownership javascript

group :assets do
  gem 'sass-rails', '3.2.5'
  gem 'coffee-rails', '3.2.2'
  gem 'uglifier', '1.3.0'
end

group :production, :integration do
  gem 'passenger', '4.0.0.rc6'
end

group :development, :test do
  gem 'sqlite3'
  gem 'unicorn-rails'
  gem 'debugger'
  gem 'selenium-webdriver'
  gem 'headless'
  gem 'rspec-rails', '>= 2.11.0'
  gem 'mocha', '0.13.3', :require => false
  gem 'cucumber-rails', '~> 1.0', :require => false
  gem 'capybara', '~>1.1.3'
  gem 'jettywrapper'
  gem 'factory_girl_rails', '~> 4.1.0'
  gem 'launchy'
  gem 'database_cleaner'
end

