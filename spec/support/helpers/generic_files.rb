# frozen_string_literal: true
module GenericFilesHelper
  def wait_for_page(redirect_url)
    Timeout.timeout(Capybara.default_max_wait_time * 5) do
      loop until current_path == redirect_url
    end
  end

  def upload_generic_file(filename)
    visit Sufia::Engine.routes.url_helpers.new_generic_file_path
    check 'terms_of_service'
    attach_file('files[]', test_file_path(filename), visible: false)
    redirect_url = find("#redirect-loc", visible: false).text(:all)
    click_button 'main_upload_start'
    wait_for_page redirect_url
    expect(page).to have_content 'Apply Metadata'
    fill_in 'generic_file_tag', with: filename + '_tag'
    fill_in 'generic_file_creator', with: filename + '_creator'
    select 'Attribution-NonCommercial-NoDerivs 3.0 United States', from: 'generic_file_rights'
    click_on 'upload_submit'
    expect(page).to have_css '#documents'
    expect(page).to have_content filename
  end

  def find_file_by_title(title)
    GenericFile.where(Solrizer.solr_name("title", :stored_searchable, type: :string) => title).first
  end
end

RSpec.configure do |config|
  config.include GenericFilesHelper
end
