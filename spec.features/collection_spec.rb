require_relative './feature_spec_helper'

include Selectors::Dashboard

describe 'Collections:' do

  let(:current_user) { create(:user) }

  def create_collection (title, creator, description)
    page.should have_content 'Create New Collection'
    fill_in('Title', with: title)
    fill_in('Creator', with: creator)
    fill_in('Description', with: description)
    click_button("Create Collection")
    page.should have_content 'Items in this Collection'
    page.should have_content(title)
    page.should have_content(creator)
    page.should have_content(description)
  end

  let(:title1) { 'Test Collection 1' }
  let(:creator) { 'Test Creator' }
  let(:description1) { 'Description for collection 1 we are testing.' }
  let(:title2) { 'Test Collection 2' }
  let(:description2) { 'Description for collection 2 we are testing.' }

  before do
    @user_key = current_user.user_key
    @gfs = []
    (0..1).each do |x|
      @gfs[x] =  GenericFile.new.tap do |f|
        f.title = "title #{x}"
        f.apply_depositor_metadata(@user_key)
        f.save
      end
    end
    @gf1 = @gfs[0]
    @gf2 = @gfs[1]
  end

  describe 'When creating a collection:' do
    before do
      sign_in_as current_user
      visit '/dashboard'
    end

    specify "I should be able to create it without any files" do
      click_button 'Create Collection'
      create_collection(title1, creator, description1)
    end

    specify "I should be able to create it with files" do
      check 'check_all'
      click_button 'Add to Collection'
      page.should have_content 'Select the collection to add your files to:'
      click_button 'Add to new Collection'
      create_collection(title1, creator, description1)
      @gfs.each do |file|
        page.should have_content file.title.first
      end
    end
  end

  describe 'When deleting a collection:' do
    before do
      @collection = Collection.new title:'collection title 1'
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata(@user_key)
      @collection.save!
    end

    specify 'I should no longer see it on my dashboard' do
      sign_in_as current_user
      visit '/dashboard'
      page.should have_content(@collection.title)
      db_item_actions_toggle(@collection).click
      click_link 'Delete Collection'
      page.should have_content 'Collection was successfully deleted'
      page.should have_content("Dashboard")
      page.should_not have_content(@collection.title)
    end
  end

  describe 'When viewing a collection:' do
    before do
      @collection = Collection.new title:'collection title 2'
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata(@user_key)
      @collection.members = [@gf1,@gf2]
      @collection.save!
    end

    it "I should see its metadata" do
      sign_in_as current_user
      visit '/dashboard'
      page.should have_content(@collection.title)
      db_item_title(@collection).click
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      # Should not have Collection Descriptive metadata table
      page.should have_content("Descriptions")
      # Should have search results / contents listing
      page.should have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
    end

  end

  describe 'When searching within a collection' do
    before do
      @collection = Collection.new title:'collection title 3'
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata(@user_key)
      @collection.members = [@gf1,@gf2]
      @collection.save!
    end

    specify "I should see the correct results" do
      sign_in_as current_user
      visit '/dashboard'
      page.should have_content(@collection.title)
      within("#document_#{@collection.noid}") do
        click_link("collection title")
      end
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      page.should have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
      fill_in('collection_search', with: @gf1.title.first)
      click_button('collection_submit')
      # Should not have Collection Descriptive metadata table
      page.should_not have_content("Descriptions")
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      # Should have search results / contents listing
      page.should have_content(@gf1.title.first)
      page.should_not have_content(@gf2.title.first)
      # Should not have Dashboard content in contents listing
      page.should_not have_content("Visibility")
    end
  end

  describe 'When updating a collection:' do
    before do
      @collection = Collection.new(title: 'collection title')
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata(@user_key)
      @collection.members = [@gf1, @gf2]
      @collection.save
    end

    specify 'I should be able to add files to it' do
      pending "Werk aint dun yet!"
    end

    specify 'I should be able to update its metadata' do
      sign_in_as current_user
      visit '/dashboard'
      page.should have_content(@collection.title)
      within("#document_#{@collection.noid}") do
        find('button.dropdown-toggle').click
        click_link('Edit Collection')
      end
      page.should have_field('collection_title', with: @collection.title)
      page.should have_field('collection_description', with: @collection.description)
      new_title = "Altered Title"
      new_description = "Completely new Description text."
      creators = ["Dorje Trollo", "Vajrayogini"]
      fill_in('Title', with: new_title)
      fill_in('Description', with: new_description)
      fill_in('Creator', with: creators.first)
      within('.span68') do
        within('.form-actions') do
          click_button('Update Collection')
        end
      end
      page.should_not have_content(@collection.title)
      page.should_not have_content(@collection.description)
      page.should have_content(new_title)
      page.should have_content(new_description)
      page.should have_content(creators.first)
    end

    specify "I should be able to remove a file from it" do
      sign_in_as current_user
      visit '/dashboard'
      page.should have_content(@collection.title)
      within("#document_#{@collection.noid}") do
        first('button.dropdown-toggle').click
        click_link('Edit Collection')
      end
      page.should have_field('collection_title', with: @collection.title)
      page.should have_field('collection_description', with: @collection.description)
      page.should have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
      within("#document_#{@gf1.noid}") do
        first('button.dropdown-toggle').click
        click_button('Remove from Collection')
      end
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      page.should_not have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
    end

    specify "I should be able to remove all files from a collection" do
      sign_in_as current_user
      visit '/dashboard'
      page.should have_content(@collection.title)
      within('#document_'+@collection.noid) do
        first('button.dropdown-toggle').click
        click_link('Edit Collection')
      end
      page.should have_field('collection_title', with: @collection.title)
      page.should have_field('collection_description', with: @collection.description)
      page.should have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
      first('input#check_all').click
      click_button('Remove From Collection')
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      page.should_not have_content(@gf1.title.first)
      page.should_not have_content(@gf2.title.first)
    end
  end
end
