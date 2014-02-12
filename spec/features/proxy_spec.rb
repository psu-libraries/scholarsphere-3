require 'spec_helper'

include Warden::Test::Helpers

describe_options = { type: :feature }
describe_options[:js] = true if ENV['JS']

describe 'collection', describe_options do
  before(:all) do
    @old_resque_inline_value = Resque.inline
    Resque.inline = true
  end

  after(:all) do
    Resque.inline = @old_resque_inline_value
    User.destroy_all
    Batch.destroy_all
    GenericFile.destroy_all
    Collection.destroy_all
  end

  let(:title1) {"Test Collection 1"}
  let(:description1) {"Description for collection 1 we are testing."}
  let(:title2) {"Test Collection 2"}
  let(:description2) {"Description for collection 2 we are testing."}

  describe 'create a proxy' do

    before (:all) do
      @user2 = FactoryGirl.find_or_create(:archivist)
    end

    after (:all) do
      @user2.destroy
    end

    it "should create proxy" do
      login_js
      visit '/'
      first('a.dropdown-toggle').click
      click_link('edit profile')
      first("td.depositor-name").should be_nil
      first('a.select2-choice').click
      find(".select2-input").set  @user2.user_key
      wait_on_page(@user2.name, time=5)
      first("div.select2-result-label").click
      wait_on_page(@user2.name, time=5)
      first("td.depositor-name").should_not be_nil
      first("td.depositor-name").text.should == @user2.name
    end
  end

  describe 'use a proxy' do

    before (:all) do
      @user1 = FactoryGirl.find_or_create(:user)
      User.any_instance.stub(:can_make_deposits_for).and_return([@user1])
    end

    after (:all) do
      @user1.destroy
    end

    it "should allow for on behalf deposit" do
      login_js('archivist1')
      visit '/'
      first('a.dropdown-toggle').click
      click_link('upload')
      wait_on_page('I have read', time=5)
      check("terms_of_service")
      select('jilluser', from: 'on_behalf_of')
      test_file_path = Rails.root.join('spec/fixtures/world.png').to_s
      page.execute_script(%Q{$("input[type=file]").css("opacity", "1").css("-moz-transform", "none");$("input[type=file]").attr('id',"fileselect");})
      attach_file("fileselect", test_file_path)
      page.first('.start').click
      page.should have_content('Apply Metadata')
      fill_in('Title 1', :with => 'MY Tite for World')
      fill_in('Keyword', :with => 'proxy')
      fill_in('Creator', :with => 'me')
      click_on('upload_submit')
      first('i.icon-plus').click
      node = first('table.expanded-details')
      node.text.should include('Depositor: jilluser')
    end
  end
end
