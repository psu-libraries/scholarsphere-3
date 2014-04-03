RSpec.configure do |config|
  config.before do
    # Clear all test emails that were sent.
    ActionMailer::Base.deliveries.clear
  end
end
