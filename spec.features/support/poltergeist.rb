# This file causes capybara to use the phantomjs browser, which is fully
# compatible with ajax
require 'capybara/poltergeist'

# Register driver and tell it not to print javascript
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 45)
end

Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist

# Configure how we should clear the database after each test.
# In the long run, we may want to move this out of the poltergeist setup,
# but for now, our database cleaning strategy is relevant to the fact that
# we are using poltergeist.
RSpec.configure do |config|

  # Phantomjs runs in a separate process so our transactions will not be visible
  # to it; we need to commit all our changes to the database.
  config.use_transactional_fixtures = false

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
    User.destroy_all
    GenericFile.destroy_all
    Batch.destroy_all
    Collection.destroy_all
    ActionMailer::Base.deliveries.clear
  end

end
