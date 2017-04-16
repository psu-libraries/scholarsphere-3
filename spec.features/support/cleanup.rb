# The other tests rely on a clean database *after* each test. So we
# clean up after ourselves here.
RSpec.configure do |config|
  config.after(:suite) do
    User.destroy_all
    GenericFile.destroy_all
    Batch.destroy_all
    Collection.destroy_all
    ActionMailer::Base.deliveries.clear
  end
end
