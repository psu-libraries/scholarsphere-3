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
    FeaturedWork.create(generic_file_id: @gf1.noid)
  end
  after(:all) do
    FeaturedWork.destroy_all
    User.destroy_all
    @gf1.destroy
  end

  before do
    login_js @user_name
    visit "/"
  end

  it "appears as a featured work", js:true do
    page.should have_content "Featured Works"
    within("#featured_container") do
      page.should have_content(@gf1.title[0])
    end
  end

  it "appears as a recently uploaded file" do
    click_link "Recently Uploaded"
    within("#recently_uploaded") do
      page.should have_content(@gf1.title[0])
    end
  end

  it "allows the user to remove it as a featured work" do
    find(".glyphicon-remove").click
    within("#featured_container") do
      page.should_not have_content(@gf1.title[0])
    end
  end
end
