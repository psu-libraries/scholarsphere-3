# The other tests rely on a clean database *before* each test. So we
# clean up after ourselves here.
RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:each) do
    #active record cleanup
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    else
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean
    end

    #fedora cleanup
    ActiveFedora::Base.delete_all

    #solr cleanup TODO What is the right way to wipe solr
    #ActiveFedora::Base.reindex_everything

    #test email cleanup
    ActionMailer::Base.deliveries.clear
  end

  config.before :each do
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :truncation
    end
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean if  Capybara.current_driver == :rack_test
  end

end
