require 'spec_helper'

include Warden::Test::Helpers

describe_options = {type: :feature}
if ENV['JS']
  describe_options[:js] = true
end

describe 'collection', describe_options do

  def create_collection (title, description)
    click_button('Create Collection')
    wait_on_page('Create New Collection').should be_true
    fill_in('Title', with:title)
    fill_in('Description', with:description)
    click_button("Create Collection")
    wait_on_page('Contained Files').should be_true
    page.has_content?(title)
    page.has_content?(description)
  end

  let (:title1) {"Test Collection 1"}
  let (:description1) {"Description for collection 1 we are testing."}
  let (:title2) {"Test Collection 2"}
  let (:description2) {"Description for collection 2 we are testing."}

  
  before(:each) do
    @old_resque_inline_value = Resque.inline
    Resque.inline = true
  end
  after(:each) do
    Resque.inline = @old_resque_inline_value
  end
  before (:all) do
    @user_key = 'jilluser'
    @gf1 =  GenericFile.new title: 'title 1' 
    @gf1.apply_depositor_metadata(@user_key)
    @gf1.save
    @gf2 =  GenericFile.new title: 'title 2' 
    @gf2.apply_depositor_metadata(@user_key)
    @gf2.save
  end
  after(:all) do
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
      create_collection title1, description1
    end         
    
    it "should create collection from the dashboard and include files", js: true do
      login_js
      go_to_dashboard
      first('input#check_all').click     
      create_collection title2, description2
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
      page.has_content?(@collection.title)
      within('#document_'+@collection.id.gsub(":","_")) do
        first('button.dropdown-toggle').click
        first(".itemtrash").click
        page.driver.browser.switch_to.alert.accept
      end
      page.should_not have_content(@collection.title)
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
    it "should show a collection", js: true do
      login_js
      go_to_dashboard
      page.has_content?(@collection.title)
      within('#document_'+@collection.id.gsub(":","_")) do
        click_link("collection title")
      end
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      page.should have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
    end
    it "should search a collection", js: true do
      login_js
      go_to_dashboard
      page.has_content?(@collection.title)
      within('#document_'+@collection.id.gsub(":","_")) do
        click_link("collection title")
      end
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      page.should have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
      fill_in('collection_search',with:@gf1.title.first)
      click_button('collection_submit')
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      page.should have_content(@gf1.title.first)
      page.should_not have_content(@gf2.title.first)

    end
    it "should remove a file from a collection", js: true do
      login_js
      go_to_dashboard
      page.has_content?(@collection.title)
      within('#document_'+@collection.id.gsub(":","_")) do
        click_link("collection title")
      end
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      page.should have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
      within('#document_'+@gf1.noid) do
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
      page.has_content?(@collection.title)
      within('#document_'+@collection.id.gsub(":","_")) do
        click_link("collection title")
      end
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      page.should have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
      first('input#check_all').click
      within('th.sm') do
        first('a.dropdown-toggle').click
      end
      within('ul.dropdown-menu') do
        click_button('Remove From Collection')
      end
      page.should have_content(@collection.title)
      page.should have_content(@collection.description)
      page.should_not have_content(@gf1.title.first)
      page.should_not have_content(@gf2.title.first)

    end
  end
end
