require 'capybara/rspec'
require 'capybara/dsl'

# Tell capybara to use css selectors, as opposed to xpath
Capybara.default_selector = :css

# Ajax can run a little slowly on some machines. Give it a chance.
Capybara.default_wait_time = 5

RSpec.configure do |config|
  config.include(Capybara::DSL)
end


require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end
Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist