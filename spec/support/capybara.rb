# frozen_string_literal: true

# Capybara is a high level DSL for driving a browser.
require 'capybara/rspec'
require 'capybara/rails'

# Tell capybara to use css selectors, as opposed to xpath
Capybara.default_selector = :css

Capybara.register_driver :chrome_headless do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome_headless

# Ajax can run a little slowly on some machines. Give it a chance.
Capybara.default_max_wait_time = 15

RSpec.configure do |config|
  # Provide support for #visit, #click_link, etc.
  config.include Capybara::DSL

  # Provide access to Rails path helpers
  config.include Rails.application.routes.url_helpers

  # Alias for shared examples
  config.alias_it_should_behave_like_to :we_can, 'We can'
  config.infer_spec_type_from_file_location!
end
