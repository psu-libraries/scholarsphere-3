# frozen_string_literal: true
module GenericWorksHelper
  def wait_for_page(redirect_url)
    Timeout.timeout(Capybara.default_max_wait_time * 5) do
      loop until current_path == redirect_url
    end
  end

  def create_work_and_upload_file(filename)
    allow(ShareNotifyJob).to receive(:perform_later)
    visit '/concern/generic_works/new'
    check 'agreement'
    click_on 'Files'
    attach_file('files[]', test_file_path(filename), visible: false)
    click_on 'Descriptions'
    fill_in 'generic_work_title', with: filename + '_title'
    fill_in 'generic_work_keyword', with: filename + '_keyword'
    fill_in 'generic_work_creator', with: filename + '_creator'
    fill_in 'generic_work_description', with: filename + '_description'
    select 'Audio', from: 'generic_work_resource_type'
    select 'Attribution-NonCommercial-NoDerivatives 4.0 International', from: 'generic_work_rights'
    click_on 'Save'
    expect(page).to have_css('h1', filename + '_title')
  end

  def find_work_by_title(title)
    GenericWork.where(Solrizer.solr_name("title", :stored_searchable, type: :string) => title).first
  end
end

RSpec.configure do |config|
  config.include GenericWorksHelper
end
