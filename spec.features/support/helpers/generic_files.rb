module GenericFilesHelper
  def upload_generic_file filename
    visit new_generic_file_path
    check 'terms_of_service'
    attach_file 'files[]', test_file_path(filename)
    click_button 'main_upload_start'
    page.should have_content 'Apply Metadata'
    fill_in 'generic_file_tag', with: filename + '_tag'
    fill_in 'generic_file_creator', with: filename + '_creator'
    select 'Attribution-NonCommercial-NoDerivs 3.0 United States', from: 'generic_file_rights'
    click_on 'upload_submit'
    page.should have_content 'My Dashboard'
    page.should have_content filename
  end

  def create_file (user, options={})
    GenericFile.new.tap do |f|
      f.title         = options[:title] || 'new title'
      f.resource_type = options[:resource_type] || 'Video'
      f.creator       = options[:creator] || 'Creator1'
      f.tag           = options[:tag] || 'Keyword1'
      f.subject       = options[:subject] || 'Subject1'
      f.language      = options[:language] || 'Language1'
      f.based_near    = options[:based_near] || 'Location1'
      f.publisher     = options[:publisher] || 'Publisher1'
      f.rights        = options[:rights] || 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'
      f.read_groups   = options[:read_groups] || ['public']
      f.apply_depositor_metadata(user.login)
      f.save!
    end
  end
end

RSpec.configure do |config|
  config.include GenericFilesHelper
end
