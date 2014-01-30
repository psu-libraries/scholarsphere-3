require 'spec_helper'

describe "User Generic File" do
  let(:user_name) {"curator1"}

  before do
    # TODO: This really shouldn't be necessary
    unspoof_http_auth
    sign_in :curator
    @user = User.where(login: 'curator1').first

  end
  context "User with generic files" do
    before do
      @gf1 =  GenericFile.new title: 'file title', resource_type: 'Video'
      @gf1.apply_depositor_metadata(@user.user_key)
      @gf1.contributor = "Mohammad"
      @gf1.creator = "Allah"
      @gf1.description = "The work by Allah"
      @gf1.publisher = "Vertigo Comics"
      @gf1.subject = "Theology"
      @gf1.language = "Arabic"
      @gf1.based_near = "Medina, Saudi Arabia"
      @gf1.related_url = "http://example.org/TheWork/"
      @gf1.save!
      visit "/"
      click_link @gf1.title.first
    end
    after do
      @gf1.destroy  rescue puts "error occured destroying object"
    end

    it "loads the page" do
      page.status_code.should == 200
      page.should have_content @gf1.title.first
    end

    it "displays a link for 'Related URL'" do
      #save_and_open_page
      page.should have_link @gf1.related_url.first
    end
  end
end
