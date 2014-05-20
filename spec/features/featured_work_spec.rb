require 'spec_helper'

describe_options = { type: :feature }
describe_options[:js] = true if ENV['JS']

describe "Showing the Generic File", {type: feature, js:true} do

  before(:all) do
    @user = FactoryGirl.find_or_create(:curator)
    @user_name = @user.login
    @gf1 =  GenericFile.new title: 'file title', resource_type: 'Video'
    @gf1.apply_depositor_metadata(@user_name)
    @gf1.read_groups = ['public']
    @gf1.save!

  end
  after(:all) do
    FeaturedWork.destroy_all
    User.destroy_all
    @gf1.destroy
  end

  before do
    # TODO: This really shouldn't be necessary
    login_js @user_name
    visit "/"
    click_link "Recently Uploaded"
    click_link @gf1.title.first
    page.should have_content("Descriptions")
  end

  it "allows a feature to be marked and deleted", js:true do
    page.should have_link "Feature"
    click_link "Feature"
    page.should have_content("Featured")
    visit '/'
    within(".new_featured_work_list") do
      page.should have_content(@gf1.title[0])
      find(".icon-remove").click
    end
    within(".new_featured_work_list") do
      page.should_not have_content(@gf1.title[0])
    end
  end
end
