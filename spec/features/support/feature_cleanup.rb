# frozen_string_literal: true
RSpec.configure do |config|
  # Clean out Redis, Fedora and Solr prior to each feature test
  config.before :each do |_example|
    begin
      redis_instance = Sufia::RedisEventStore.instance
      redis_instance.keys('events:*').each { |key| redis_instance.del key }
      redis_instance.keys('User:*').each { |key| redis_instance.del key }
      redis_instance.keys('GenericWork:*').each { |key| redis_instance.del key }
    rescue => e
      Logger.new(STDOUT).warn "WARNING -- Redis might be down: #{e}"
    end
    ActiveFedora::Cleaner.clean!
  end

  config.after(:each) do
    sleep 0.1
    Capybara.reset_sessions!
    sleep 0.1
    page.driver.reset!
    sleep 0.1
  end
end
