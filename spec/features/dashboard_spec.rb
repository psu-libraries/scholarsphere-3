require 'spec_helper'

module Dashboard
  describe 'view_dashboard' do
    after(:all) do
      GenericFile.destroy_all
      Collection.destroy_all
    end
    let(:user) { FactoryGirl.find_or_create(:user) }
  
    describe 'visit dashboard' do
      before do
        @collection = Collection.new title:'collection title'
        @collection.description = 'collection description'
        @collection.apply_depositor_metadata(user.user_key)
        @collection.save!
        @gf1 =  GenericFile.new title: 'file title', resource_type: 'Video' 
        @gf1.apply_depositor_metadata(user.user_key)
        @gf1.save!
      end

      it "should visit dashboard" do
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
