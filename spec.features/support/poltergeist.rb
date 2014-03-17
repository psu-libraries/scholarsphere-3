# This file causes capybara to use the phantomjs browser, which is fully
# compatible with ajax
require 'capybara/poltergeist'

# Register driver and tell it not to print javascript
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end

Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist

# Phantomjs runs in a separate process so our transactions will not be visible
# to it; we need to commit all our changes to the database.
RSpec.configure do |config|
  config.use_transactional_fixtures = false
end