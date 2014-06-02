require 'spec_helper'

describe "Showing the Generic File" do

  before(:all) do
      @user_name = "curator1"
      @gf1 =  GenericFile.new title: 'file title', resource_type: 'Video'
      @gf1.apply_depositor_metadata(@user_name)
      @gf1.contributor = "Mohammad"
      @gf1.creator = "Allah"
      @gf1.description = "The work by Allah http://example.org/TheDescriptionLink/"
      @gf1.publisher = "Vertigo Comics"
      @gf1.subject = "Theology"
      @gf1.language = "Arabic"
      @gf1.based_near = "Medina, Saudi Arabia"
      @gf1.related_url = "http://example.org/TheRelatedURLLink/"
      @gf1.tag = "tag string!"
      @gf1.rights = "http://creativecommons.org/licenses/by-nc-nd/3.0/us/"
      @gf1.read_groups = ['public']
      @gf1.save!

      @gf2 =  GenericFile.new title: 'different file title', resource_type: 'Video'
      @gf2.apply_depositor_metadata(@user_name)
      @gf2.save!
  end
  after(:all) do
    @gf1.destroy
    @gf2.destroy
  end

  before do
    # TODO: This really shouldn't be necessary
    unspoof_http_auth
    sign_in :curator
    @user = User.where(login: @user_name).first
    visit "/"
    click_link "Recently Uploaded"
  end

  context "User with generic files" do
    before do
      click_link @gf1.title.first
      page.should have_content("Descriptions")
    end

    it "loads the page" do
      page.status_code.should == 200
      page.should have_content @gf1.title.first
    end

    it "displays a link for creator" do
      check_page(@gf1.creator.first)
    end

    it "displays a link for contributor" do
      check_page(@gf1.contributor.first)
    end

    it "displays a link for publisher" do
      check_page(@gf1.publisher.first)
    end

    it "displays a link for subject" do
      check_page(@gf1.subject.first)
    end

    it "displays a link for language" do
      check_page(@gf1.language.first)
    end

    it "displays a link for based_near" do
      check_page(@gf1.based_near.first)
    end

    it "displays a link for tag" do
      check_page(@gf1.tag.first)
    end

    it "displays a link for rights" do
      check_page(Sufia.config.cc_licenses_reverse[@gf1.rights.first])
    end

    it "displays a link for feature" do
      page.should have_link "Feature"
    end

    it "displays a link for all the linkable items" do
      page.should have_link 'http://example.org/TheDescriptionLink/'
      page.should have_link @gf1.related_url.first
    end

    it "displays Mendeley modal" do
      click_link "Mendeley"
      page.should have_css(".modal-header")
    end

    it "displays Zotero modal" do
      click_link "Zotero"
      page.should have_css(".modal-header")
    end

    context "private file" do
      before do
        @gf1.read_groups = []
        @gf1.save!
      end
      after do
        @gf1.read_groups = ['public']
        @gf1.save!
      end
      it "does not display a link for feature" do
        save_and_open_page
        page.should have_no_link "Feature"
      end

    end

  end
  context "thumbnail display" do
    it "shows image thumbnail" do
      allow_any_instance_of(GenericFile).to receive(:image?).and_return(true)
      click_link @gf1.title.first
      page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(@gf1.noid, {datastream_id: 'thumbnail'})}']")
    end
    it "shows pdf thumbnail" do
      allow_any_instance_of(GenericFile).to receive(:pdf?).and_return(true)
      click_link @gf1.title.first
      page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(@gf1.noid, {datastream_id: 'thumbnail'})}']")
    end
    it "shows video thumbnail" do
      allow_any_instance_of(GenericFile).to receive(:video?).and_return(true)
      click_link @gf1.title.first
      page.should have_css("video")
    end
    it "shows audio thumbnail" do
      allow_any_instance_of(GenericFile).to receive(:audio?).and_return(true)
      click_link @gf1.title.first
      page.should have_css("audio")
    end
    it "shows default thumbnail" do
      click_link @gf1.title.first
      page.should have_css("img[src*='/assets/default.png']")
    end

  end

  def check_page(link_name)
      page.should have_link link_name
      click_on link_name
      page.should have_content @gf1.title.first
      page.should_not have_content @gf2.title.first
  end
end
