module GenericFilesHelper
  def upload_generic_file filename
    visit new_generic_file_path
    check 'terms_of_service'
    attach_file('files[]', test_file_path(filename))
    click_button 'main_upload_start'
    page.should have_content 'Apply Metadata'
    fill_in 'generic_file_tag', with: filename + '_tag'
    fill_in 'generic_file_creator', with: filename + '_creator'
    select 'Attribution-NonCommercial-NoDerivs 3.0 United States', from: 'generic_file_rights'
    click_on 'upload_submit'
    page.should have_content 'My Dashboard'
    page.should have_content filename
  end
end

RSpec.configure do |config|
  config.include GenericFilesHelper
end
