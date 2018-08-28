# frozen_string_literal: true

require_relative '../benchmark_helper.rb'

RSpec.shared_examples 'uploading from Box with Resque' do
  it 'logs in and uploads files from my Box account' do
    logger.info("Starting #{self}")
    login_and_navigate_to_files
    upload_files_from_box
    submit_new_work

    logger.info('Detecting when the page has changed to the new work')
    browser.find_element(:xpath, '/html/body/div[1][@class="alert alert-success alert-dismissable"]')

    logger.info('Waiting until work elements are present')
    refresh_until_element_present(
      element_path: '/html/body/div[1]/div/div[2]/div/table/tbody/tr[NUMBER]/td[1]/a/img',
      browser: browser
    )

    logger.info('Waiting until resque jobs are complete')
    refresh_until_resque_complete(
      element_path: '/html/body/div[1]/div/div[2]/div/table/tbody/tr[NUMBER]/td[1]/a/img',
      browser: browser
    )

    logger.info('Completed test, quitting browser')
    browser.quit
  end
end

RSpec.describe 'Benchmark tests: Uploads' do
  context 'Chrome' do
    let(:browser) { chrome_driver }

    it_behaves_like 'uploading from Box with Resque'
  end

  context 'Firefox' do
    let(:browser) { firefox_driver }

    it_behaves_like 'uploading from Box with Resque'
  end
end
