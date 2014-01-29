require 'spec_helper'

describe "User Trophy" do
  let(:user_name) {"curator1"}

  before do
    # TODO: This really shouldn't be necessary
    unspoof_http_auth
    sign_in :curator
    @user = User.where(login: 'curator1').first

  end
  context "User without trophies" do
    before do
      visit "/"
    end

    it "allows to view profile" do
      click_link user_name
      page.status_code.should == 200
    end

  end
  context "User with trophies" do
    before do
      @gf1 =  GenericFile.new title: 'file title', resource_type: 'Video'
      @gf1.apply_depositor_metadata(@user.user_key)
      @gf1.save!

      @trophy = Trophy.new
      @trophy.user_id = @user.id
      @trophy.generic_file_id = @gf1.noid
      @trophy.save

      visit "/"
    end
    after do
      @trophy.destroy rescue puts "error occured destroying object"
      @gf1.destroy  rescue puts "error occured destroying object"
    end

    it "allows to view profile with trophies" do
      click_link user_name
      page.status_code.should == 200
      page.should have_content @gf1.title
    end
  end
end
