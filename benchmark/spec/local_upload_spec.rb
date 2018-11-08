# frozen_string_literal: true

require_relative '../benchmark_helper.rb'

RSpec.shared_examples 'uploading locally' do
  it 'logs in and uploads files' do
    logger.info("Starting #{self}")
    login_and_navigate_to_files
    upload_files_from_my_computer
    submit_new_work
    refresh_until_complete
    logger.info('Completed test, quitting browser')
    browser.quit
  end
end

RSpec.describe 'Benchmark tests: Local upload' do
  let(:browser) { driver }

  it_behaves_like 'uploading locally'
end
