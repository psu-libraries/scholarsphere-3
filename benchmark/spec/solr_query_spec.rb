# frozen_string_literal: true

require_relative '../benchmark_helper'

RSpec.describe 'Benchmark tests: Querying' do
  before(:context) do
    driver.get(scholarsphere_url)
  end

  after(:context) do
    driver.quit
  end

  BenchmarkQuery::SEARCH_QUERY_RUNS.times do |count|
    BenchmarkQuery::SEARCH_QUERY_STRINGS.each do |query|
      it "Run #{count + 1} of #{BenchmarkQuery::SEARCH_QUERY_RUNS}: #{query}" do
        driver.find_element(:id, 'search-field-header').clear
        driver.find_element(:id, 'search-field-header').send_keys(query)
        driver.find_element(:id, 'search-submit-header').click
      end
    end
  end
end
