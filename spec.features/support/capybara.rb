# Capybara is a high level DSL for driving a browser.
require 'capybara/rspec'
require 'capybara/rails'

# Tell capybara to use css selectors, as opposed to xpath
Capybara.default_selector = :css

# Ajax can run a little slowly on some machines. Give it a chance.
Capybara.default_wait_time = 15

RSpec.configure do |config|
  # Provide support for #visit, #click_link, etc.
  config.include(Capybara::DSL)

  # Provide access to Rails path helpers
  config.include Rails.application.routes.url_helpers
end
