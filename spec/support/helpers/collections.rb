module CollectionsHelper
  def create_collection(title, creator, description)
    expect(page).to have_content 'Create New Collection', wait: Capybara.default_wait_time*2
    fill_in 'Title', with: title
    fill_in 'Creator', with: creator
    fill_in 'Description', with: description
    click_button 'Create Collection'
    expect(page).to have_content 'Items in this Collection'
    expect(page).to have_content title
    expect(page).to have_content creator
    expect(page).to have_content description
  end
end

RSpec.configure do |config|
  config.include CollectionsHelper
end
