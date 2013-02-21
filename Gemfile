# workaround for "invalid byte sequence in US-ASCII (ArgumentError)" breaking the Jenkins build
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'http://rubygems.org'

# Ruby on Rails components
gem 'rails', '3.2.11'
gem 'mysql2', '0.3.11'
gem 'rb-readline', '0.4.2'

# Hydra community components
gem 'sufia', '0.0.8'
#gem 'sufia', :path => '../sufia' 
#gem 'sufia', :git =>'git://github.com/curationexperts/sufia.git', :ref=>'1d78dfc6364c4ab893613e1931b5b59872e79005'
# pointing to stewardship until pull request is complete
#gem 'hydra-batch-edit' 
gem 'hydra-batch-edit', :git => 'git://github.com/psu-stewardship/hydra-batch-edit.git'
gem 'hydra-ldap', '0.1.0'
gem 'noid', '0.5.5'
gem 'jquery-rails', '2.1.4'
gem 'resque-pool', '0.3.0'
# NOTE: the :require arg is necessary on Linux-based hosts
gem 'rmagick', '2.13.1', :require => 'RMagick'
gem 'devise', '2.1.3'
gem 'paperclip', '3.3.0'
gem 'daemons', '1.1.9'
gem 'execjs', '1.4.0'
gem 'therubyracer', '0.10.2'
gem 'zipruby', '0.3.6'
gem 'rails_autolink', '1.0.9'
gem 'acts_as_follower', '0.1.1'
gem 'nest', '1.1.1'
gem 'sitemap', '0.3.2'
gem 'yaml_db', '0.2.3'
gem 'mailboxer', '0.8.0'
gem 'mail_form'
gem 'clamav', '0.4.1'
gem 'will_paginate', '3.0.3'
gem 'equivalent-xml', '0.3.0'
gem 'font-awesome-sass-rails'
gem 'execjs', '1.4.0' 
gem 'therubyracer', '0.10.2' 

group :assets do
  gem 'sass-rails', '3.2.5'
  gem 'coffee-rails', '3.2.2'
  gem 'uglifier', '1.3.0'
end

group :production, :integration do
  gem 'passenger', '3.0.13'
end

group :development, :test do
  gem 'sqlite3'
  gem 'unicorn-rails'
  gem "debugger"
#  gem 'activerecord-import'
#  gem "rails_indexes", :git => "git://github.com/warpc/rails_indexes.git", :ref => '4a550270'
  gem 'selenium-webdriver'
  gem 'headless'
#  gem 'rspec', '2.11.0'
  gem 'rspec-rails', '>= 2.11.0'
#  gem 'ruby-prof'
  gem 'mocha', '0.12.4', :require => false
  gem 'cucumber-rails', '~> 1.0', :require => false
  gem 'capybara', '~>1.1.3'
  gem 'capybara', '~>1.1.3'
  gem "jettywrapper"
  gem "factory_girl_rails", "~> 4.1.0"
  gem 'launchy'
  gem 'database_cleaner'
end # (leave this comment here to catch a stray line inserted by blacklight!)

gem "unicode", :platforms => [:mri_18, :mri_19]
gem "bootstrap-sass"
