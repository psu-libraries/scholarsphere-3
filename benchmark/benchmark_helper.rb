# frozen_string_literal: true

require 'rspec'
require 'selenium-webdriver'
require 'faker'
require 'pry-byebug'

Pathname.pwd.join('support').children.each { |f| require f }

RSpec.configure do |config|
  config.include BenchmarkConfig
  config.include BenchmarkSteps
  config.include BenchmarkLogger
  config.include BenchmarkQuery
  config.include BenchmarkDriver
end
