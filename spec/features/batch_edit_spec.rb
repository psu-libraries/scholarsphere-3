require 'spec_helper'

include Warden::Test::Helpers

describe_options = {type: :feature}
if ENV['JS']
  describe_options[:js] = true
end

describe 'batch_edit', describe_options do
  before(:each) do
    @old_resque_inline_value = Resque.inline
    Resque.inline = true
  end
  after(:each) do
    Resque.inline = @old_resque_inline_value
  end
  after(:all) do
    User.destroy_all
    Batch.destroy_all
    GenericFile.destroy_all
  end
  
  let (:subject) {"fffzzz"}

  describe 'batch modify all files' do   
    let(:agreed_to_terms_of_service) { false }
    before (:each) do
      @gf1 =  GenericFile.new title: 'title 1' 
      @gf1.apply_depositor_metadata('jilluser')
      @gf1.save
      @gf2 =  GenericFile.new title: 'title 2' 
      @gf2.apply_depositor_metadata('jilluser')
      @gf2.save
    end
    
           
    
    it "should edit all files", js: true do
      login_js
      go_to_dashboard
      first('input#check_all').click
      click_button('Edit Selected')
      page.has_content?('2 files')
      page.has_content?(@gf1.title.first)
      page.has_content?(@gf2.title.first)
      click_link('Subject')
      fill_in('Subject', with:subject)
      click_button("Save changes")
      wait_until(10) do
        page.has_content?('Changes Saved')
      end
      within('#masthead') do
      fill_in 'search-field-header', with:subject
        click_button("Go")
      end
      wait_until(10) do
        page.has_content?('Search Results')
      end
      page.has_content?(@gf1.title.first)
      page.has_content?(@gf2.title.first)
      
    end

    it "should delete all files", js: true do
      login_js
      visit '/'
      first('a.dropdown-toggle').click
      click_link('my dashboard')
      wait_until(10) do
        page.has_content?('My Dashboard')
      end
      first('input#check_all').click
      click_button('Delete Selected')
      page.driver.browser.switch_to.alert.accept
      page.has_content?('My Dashboard')
      page.should_not have_content(@gf1.title.first)
      page.should_not have_content(@gf2.title.first)      
    end

  end
end
