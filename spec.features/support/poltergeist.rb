# This file causes capybara to use the phantomjs browser, which is fully
# compatible with ajax
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  # Register driver and tell it not to print javascript
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end

Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist