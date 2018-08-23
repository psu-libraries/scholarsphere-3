# frozen_string_literal: true

require_relative '../benchmark_helper'

RSpec.describe 'Benchmark tests: Querying' do
  context 'with Chrome' do
    before(:context) do
      chrome_driver.get(scholarsphere_url)
    end

    after(:context) do
      chrome_driver.quit
    end

    BenchmarkQuery::SEARCH_QUERY_RUNS.times do |count|
      BenchmarkQuery::SEARCH_QUERY_STRINGS.each do |query|
        it "Run #{count + 1} of #{BenchmarkQuery::SEARCH_QUERY_RUNS}: #{query}" do
          logger.info("Starting #{self} on #{scholarsphere_url}")
          chrome_driver.find_element(:id, 'search-field-header').clear
          chrome_driver.find_element(:id, 'search-field-header').send_keys(query)
          chrome_driver.find_element(:id, 'search-submit-header').click
        end
      end
    end
  end

  context 'with Firefox' do
    before(:context) do
      firefox_driver.get(scholarsphere_url)
    end

    after(:context) do
      firefox_driver.quit
    end

    BenchmarkQuery::SEARCH_QUERY_RUNS.times do |count|
      BenchmarkQuery::SEARCH_QUERY_STRINGS.each do |query|
        it "Run #{count + 1} of #{BenchmarkQuery::SEARCH_QUERY_RUNS}: #{query}" do
          firefox_driver.find_element(:id, 'search-field-header').clear
          firefox_driver.find_element(:id, 'search-field-header').send_keys(query)
          firefox_driver.find_element(:id, 'search-submit-header').click
        end
      end
    end
  end
end
