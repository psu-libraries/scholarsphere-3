module CollectionsHelper
  def create_collection (title, creator, description)
    page.should have_content 'Create New Collection', wait: Capybara.default_wait_time*2
    fill_in 'Title', with: title
    fill_in 'Creator', with: creator
    fill_in 'Description', with: description
    click_button 'Create Collection'
    page.should have_content 'Items in this Collection'
    page.should have_content title
    page.should have_content creator
    page.should have_content description
  end
end

RSpec.configure do |config|
  config.include CollectionsHelper
end
