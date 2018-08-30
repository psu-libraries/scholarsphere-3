# frozen_string_literal: true

require_relative '../benchmark_helper.rb'

RSpec.shared_examples 'uploading from Box' do
  it 'logs in and uploads files from my Box account' do
    logger.info("Starting #{self}")
    login_and_navigate_to_files
    upload_files_from_box
    submit_new_work
    refresh_until_complete
    logger.info('Completed test, quitting browser')
    browser.quit
  end
end

RSpec.describe 'Benchmark tests: Cloud upload' do
  let(:browser) { driver }

  it_behaves_like 'uploading from Box'
end
