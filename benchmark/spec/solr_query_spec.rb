# frozen_string_literal: true

require 'selenium-webdriver'
require 'rspec'
require_relative '../variables.rb'

search_query_strings = [
  'development',
  'signorella',
  'japanese manga',
  'lidar showalter computational',
  'chouest',
  'maps',
  'lasso and scad',
  'dataset',
  'hegemony resistence of matter',
  'mystification reification',
  'lada gaga',
  'science graphic novels for academic library',
  'equilibria',
  'circular',
  'behaioralparadigm_data.zip',
  'tanwybleeeg',
  'blatheringblatherskite',
  '^*)a3alkdsf3#%^@',
  'anesthesiology',
  'brian w. miller',
  '7z',
  'story of nylon',
  'nautilus',
  'geológica',
  'Heat transfer and pressure drop simulation results for jet impingement array heat sink with interspersed fluid extraction ports',
  'open access',
  'ogontz',
  'archives',
  'anchovies',
  'Emotional Intelligence and Its Effects on Moral Reasoning'
]

5.times do |count|
  [:chrome, :firefox].each do |driver|
    describe "#{count + 1}: Test Solr Queries" do
      before(:context) do
        case driver
        when :chrome
          options = Selenium::WebDriver::Chrome::Options.new
        when :firefox
          options = Selenium::WebDriver::Firefox::Options.new
        end
        if @headless then options.add_argument('--headless') end
        @driver = Selenium::WebDriver.for driver, options: options
        @driver.manage.timeouts.implicit_wait = @implicit_wait_time
        @driver.manage.window.maximize
      end

      before do
        @driver.get(@scholarsphere_url)
      end

      after(:context) do
        @driver.quit
      end

      search_query_strings.each do |query|
        it "queries #{driver} for #{query}" do
          @driver.find_element(:id, 'search-field-header').clear
          @driver.find_element(:id, 'search-field-header')
            .send_keys(query)
          @driver.find_element(:id, 'search-submit-header').click
        end
      end
    end
  end
end
