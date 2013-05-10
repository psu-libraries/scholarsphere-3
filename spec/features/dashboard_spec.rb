require 'spec_helper'

module Dashboard
  
  describe_options = {type: :feature}
  
  describe 'view_dashboard', describe_options do
    before(:each) do
      Warden.test_mode!
      @old_resque_inline_value = Resque.inline
      Resque.inline = true
    end
    after(:each) do
     Warden.test_reset!
     Resque.inline = @old_resque_inline_value
    end
    after(:all) do
      GenericFile.destroy_all
      Collection.destroy_all
    end
    let(:user) { FactoryGirl.find_or_create(:user) }
  
    describe 'visit dashboard' do
      it "should visit dashboard" do
        @collection = Collection.new title:'collection title'
        @collection.description = 'collection description'
        @collection.apply_depositor_metadata(user.user_key)
        @collection.save
        @gf1 =  GenericFile.new title: 'file title' 
        @gf1.apply_depositor_metadata(user.user_key)
        @gf1.save

        login_as (user.user_key)
        visit ('/')
        click_link('my dashboard')
        page.has_content?('My Dashboard').should be_true
        page.has_content?(@gf1.title.first).should be_true
        page.has_content?(@collection.title).should be_true
        page.has_content?(@collection.description).should be_true
        
      end
    end
  end
end
