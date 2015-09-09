module GenericFilesHelper
  def wait_for_page(redirect_url)
    Timeout.timeout(Capybara.default_max_wait_time*5) do
      loop until current_path == redirect_url
    end
  end

  def upload_generic_file(filename)
    visit Sufia::Engine.routes.url_helpers.new_generic_file_path
    check 'terms_of_service'
    attach_file 'files[]', test_file_path(filename)
    redirect_url = find("#redirect-loc", visible:false).text(:all)
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

  def create_file(user, options={})
    GenericFile.new.tap do |f|
      f.title         = [options[:title] || 'Title'].flatten
      f.resource_type = [options[:resource_type] || 'Video'].flatten
      f.creator       = [options[:creator] || 'Creator'].flatten
      f.contributor   = [options[:contributor] || 'Contributor'].flatten
      f.description   = [options[:description] || "Description http://example.org/TheDescriptionLink/"].flatten
      f.tag           = [options[:tag] || 'Keyword'].flatten
      f.rights        = [options[:rights] || 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'].flatten
      f.publisher     = [options[:publisher] || 'Publisher'].flatten
      f.subject       = [options[:subject] || 'Subject'].flatten
      f.language      = [options[:language] || 'Language'].flatten
      f.based_near    = [options[:based_near] || 'Location'].flatten
      f.related_url   = [options[:related_url] || "http://example.org/TheRelatedURLLink/"].flatten
      f.read_groups   = options[:read_groups] || ['public']
      f.apply_depositor_metadata(user.login)
      f.save!
    end
  end

  def find_file_by_title(title)
    GenericFile.where(Solrizer.solr_name("title", :stored_searchable, type: :string) => title).first
  end
end

RSpec.configure do |config|
  config.include GenericFilesHelper
end
