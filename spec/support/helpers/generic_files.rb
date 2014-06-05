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
    page.should have_css '#documents'
    page.should have_content filename
  end

  def create_file (user, options={})
    GenericFile.new.tap do |f|
      f.title         = options[:title] || 'Title'
      f.resource_type = options[:resource_type] || 'Video'
      f.creator       = options[:creator] || 'Creator'
      f.contributor   = options[:contributor] || 'Contributor'
      f.description   = options[:description] || "Description http://example.org/TheDescriptionLink/"
      f.tag           = options[:tag] || 'Keyword'
      f.rights        = options[:rights] || 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'
      f.publisher     = options[:publisher] || 'Publisher'
      f.subject       = options[:subject] || 'Subject'
      f.language      = options[:language] || 'Language'
      f.based_near    = options[:based_near] || 'Location'
      f.related_url   = options[:related_url] || "http://example.org/TheRelatedURLLink/"
      f.read_groups   = options[:read_groups] || ['public']
      f.apply_depositor_metadata(user.login)
      f.save!
    end
  end

  def find_file_by_title title
    GenericFile.where(Solrizer.solr_name("desc_metadata__title", :stored_searchable, type: :string)=>title).first
  end
end

RSpec.configure do |config|
  config.include GenericFilesHelper
end
