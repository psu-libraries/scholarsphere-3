# frozen_string_literal: true
RSpec.configure do |config|
  # Clean Fedora and Solr prior to each feature test
  config.before :each do |_example|
    begin
      $redis.keys('events:*').each { |key| $redis.del key }
      $redis.keys('User:*').each { |key| $redis.del key }
      $redis.keys('GenericFile:*').each { |key| $redis.del key }
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
