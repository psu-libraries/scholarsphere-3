require 'spec_helper'

include Warden::Test::Helpers

describe_options = { type: :feature }
describe_options[:js] = true if ENV['JS']

describe 'collection', describe_options do
  def create_collection (title, description)
    first('#hydra-collection-add').click
    wait_on_page('Create New Collection').should be_true
    fill_in('Title', with: title)
    fill_in('Description', with: description)
    click_button("Create Collection")
    wait_on_page('Items in this Collection').should be_true
    page.should have_content(title)
    page.should have_content(description)
  end

  let (:title1) {"Test Collection 1"}
  let (:description1) {"Description for collection 1 we are testing."}
  let (:title2) {"Test Collection 2"}
  let (:description2) {"Description for collection 2 we are testing."}

  before (:all) do
    @old_resque_inline_value = Resque.inline
    Resque.inline = true
    @user_key = 'jilluser'
    @gf1 =  GenericFile.new.tap do |f|
      f.title = 'title 1'
      f.apply_depositor_metadata(@user_key)
      f.save
    end
    @gf2 =  GenericFile.new.tap do |f|
      f.title = 'title 2'
      f.apply_depositor_metadata(@user_key)
      f.save
    end
  end

  after(:all) do
    Resque.inline = @old_resque_inline_value
    User.destroy_all
    Batch.destroy_all
    GenericFile.destroy_all
    Collection.destroy_all
  end

  describe 'create collection' do

    after(:all) do
      Collection.destroy_all
    end

    it "should create and empty collection from the dashboard", js: true do
      login_js
      go_to_dashboard
      create_collection(title1, description1)
    end

    it "should create collection from the dashboard and include files", js: true do
      login_js
      go_to_dashboard
      first('input#check_all').click
      create_collection(title2, description2)
    end
  end

  describe 'delete collection' do
    before (:each) do
      @collection = Collection.new title:'collection title'
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata(@user_key)
      @collection.save
    end

    it "should delete a collection", js: true do
      login_js
      go_to_dashboard
      page.should have_content(@collection.title)
      within('#document_'+@collection.noid) do
        first('button.dropdown-toggle').click
        first(".itemtrash").click
      end
      page.should_not have_content(@collection.title)
      page.should have_content("Dashboard")
    end
  end

  describe 'show collection' do
    before (:each) do
      @collection = Collection.new title:'collection title'
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata(@user_key)
      @collection.members = [@gf1,@gf2]
      @collection.save
    end

    it "should show a collection with a listing of Descriptive Metadata and catalog-style search results", js: true do
      login_js
      go_to_dashboard
      page.should have_content(@collection.title)
      within('#document_'+@collection.noid) do
        click_link("collection title")
      end
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      # Should not have Collection Descriptive metadata table
      page.should have_content("Descriptions")
      # Should have search results / contents listing
      page.should have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
    end

    it "should hide collection descriptive metadata when searching a collection", js: true do
      login_js
      go_to_dashboard
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

  describe 'edit collection' do
    before (:each) do
      @collection = Collection.new(title: 'collection title')
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata(@user_key)
      @collection.members = [@gf1, @gf2]
      @collection.save
    end

    it "should edit and update collection metadata" do
      login_js
      go_to_dashboard
      page.should have_content(@collection.title)
      within("#document_#{@collection.noid}") do
        find('button.dropdown-toggle').click
        click_link('Edit Collection')
      end
      page.should have_field('#collection_title', with: @collection.title)
      page.should have_field('#collection_description', with: @collection.description)
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

    it "should remove a file from a collection", js: true do
      login_js
      go_to_dashboard
      page.should have_content(@collection.title)
      within("#document_#{@collection.noid}") do
        first('button.dropdown-toggle').click
        click_link('Edit Collection')
      end
      page.should have_field('#collection_title', with: @collection.title)
      page.should have_field('#collection_description', with: @collection.description)
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

    it "should remove all files from a collection", js: true do
      login_js
      go_to_dashboard
      page.should have_content(@collection.title)
      within('#document_'+@collection.noid) do
        first('button.dropdown-toggle').click
        click_link('Edit Collection')
      end
      page.should have_field('#collection_title', with: @collection.title)
      page.should have_field('#collection_description', with: @collection.description)
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
