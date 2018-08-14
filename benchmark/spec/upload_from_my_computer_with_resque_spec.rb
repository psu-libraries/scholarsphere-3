# frozen_string_literal: true

require 'selenium-webdriver'
require 'rspec'
require 'byebug'
require_relative '../variables.rb'

[:firefox, :chrome].each do |driver|
  describe 'Benchmark duration for editing single work' do
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

    after(:context) do
      @driver.quit
    end

    it 'Navigates to the scholarsphere webpage' do
      @driver.get(@scholarsphere_url)
    end

    it 'Logs into the scholarsphere application' do
      @driver.find_element(:link, 'Login').click
      @driver.find_element(:id, 'login').clear
      @driver.find_element(:id, 'login').send_keys ENV['SELENIUM_USERNAME']
      @driver.find_element(:id, 'password').clear
      @driver.find_element(:id, 'password').send_keys ENV['SELENIUM_PASSWORD']
      @driver.find_element(:xpath, '/html/body/div[4]/span/main/form/button').click
    end

    it 'Navigates to the "New Work" page' do
      @driver.get(@scholarsphere_url + '/concern/generic_works/new')
    end

    it 'Fills out basic metadata' do
      @driver.find_element(:id, 'generic_work_title').clear
      @driver.find_element(:id, 'generic_work_title').send_keys('upload_from_my_computer')
      @driver.find_element(:id, 'generic_work_subtitle').clear
      @driver.find_element(:id, 'generic_work_subtitle').send_keys('uploaded from filesystem')
      @driver.find_element(:id, 'generic_work[creators][0][given_name]').clear
      @driver.find_element(:id, 'generic_work[creators][0][given_name]').send_keys(@given_name)
      @driver.find_element(:id, 'generic_work[creators][0][sur_name]').clear
      @driver.find_element(:id, 'generic_work[creators][0][sur_name]').send_keys(@sur_name)
      @driver.find_element(:id, 'generic_work[creators][0][display_name]').clear
      @driver.find_element(:id, 'generic_work[creators][0][display_name]').send_keys(@display_name)
      @driver.find_element(:id, 'generic_work[creators][0][email]').clear
      @driver.find_element(:id, 'generic_work[creators][0][email]').send_keys(@email)
      @driver.find_element(:id, 'generic_work[creators][0][psu_id]').clear
      @driver.find_element(:id, 'generic_work[creators][0][psu_id]').send_keys(@psu_id)
      @driver.find_element(:id, 'generic_work_keyword').clear
      @driver.find_element(:id, 'generic_work_keyword').send_keys(@keyword)
      @driver.find_element(:id, 'generic_work_rights').click
      @driver.find_element(:xpath, '//*[@id="generic_work_rights"]/option[2]').click
      @driver.find_element(:id, 'generic_work_description').clear
      @driver.find_element(:id, 'generic_work_description').send_keys(@work_description)
      @driver.find_element(:xpath, '//*[@id="generic_work_resource_type"]/option[1]').click
    end

    it 'Navigates to the Files page' do
      @driver.find_element(:xpath, '//*[@id="new_generic_work"]/div/div[1]/ul/li[2]/a').click
    end

    it 'Selects files for upload' do
      @sample_files.each do |file|
        @driver.find_element(:id, 'inputfiles')
          .send_keys("#{@samples_directory}/#{file}")
      end
    end

    it 'Uploads work file' do
      @driver.find_element(:xpath, '//*[@id="all_files"]/div[1]/button').click
    end

    it 'Waits until the file is finished uploading' do
      @sample_files.each_with_index do |_file, index|
        @driver.find_element(
          :xpath,
          '/html/body/div[1]/div/form/div/div[1]/div/div[2]/div/div/table/tbody/tr['\
					"#{index + 1}"\
					"]/td[3]/button[@class='btn btn-danger delete']"
        )
      end
    end

    it 'selects default embargo option' do
      @driver.find_element(:id, 'generic_work_visibility_embargo').click
    end

    it 'accepts depositor agreement' do
      @driver.find_element(:id, 'agreement').click
    end

    it 'submits new work' do
      @driver.find_element(:id, 'with_files_submit').click
    end

    it 'detects when the page has changed to the new work' do
      @driver.find_element(:xpath, '/html/body/div[1][@class="alert alert-success alert-dismissable"]')
    end

    it 'Waits until work elements are present' do
      refresh_until_element_present('/html/body/div[1]/div/div[2]/div/table/tbody/tr[NUMBER]/td[1]/a/img')
    end

    it 'Waits until resque jobs are complete' do
      refresh_until_resque_complete('/html/body/div[1]/div/div[2]/div/table/tbody/tr[NUMBER]/td[1]/a/img')
    end
  end
end

def refresh_until_element_present(element_path)
  @driver.manage.timeouts.implicit_wait = 1
  begin
    @sample_files.each_with_index do |_filename, index|
      element_path_iteration = element_path.sub(/NUMBER/, (index + 1).to_s)
      @driver.find_element(:xpath, element_path_iteration)
    end
  rescue StandardError
    Selenium::WebDriver::Error::NoSuchElementError
    @driver.navigate.refresh
    refresh_until_element_present(element_path)
  end
  @driver.manage.timeouts.implicit_wait = @implicit_wait_time
end

def refresh_until_resque_complete(element_path)
  @sample_files.each_with_index do |_filename, index|
    element_path_iteration = element_path.sub(/NUMBER/, (index + 1).to_s)
    if @driver.find_element(:xpath, element_path_iteration).attribute('src').include?('/assets')
      @driver.navigate.refresh
      refresh_until_resque_complete(element_path)
    end
  end
end
