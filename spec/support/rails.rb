# frozen_string_literal: true
# Load the Ruby on Rails app

ENV['RAILS_ENV'] ||= 'test'

require_relative '../../config/environment'
require 'rspec/rails'
