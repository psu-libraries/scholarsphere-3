require 'spec_helper'

include Warden::Test::Helpers

describe_options = { type: :feature }

describe "Visting the home page" do
  before :all do
    @blk = ContentBlock.find_or_create_by( name: "marketing_text").tap do |market|
      market.value = "Share. Manage. Preserve."
      market.save
    end

  end

  after :all do
    @blk.destroy
  end

  before do
    # TODO: This really shouldn't be necessary
    unspoof_http_auth
    sign_in :curator
    @user = User.where(login: 'curator1').first
  end

  it "loads the page when there are no groups" do
    visit '/'
    page.should have_content "#{@user.login}"
  end

  context "when there are only a couple of groups" do
    before { add_groups_to_user(2) }
    it "loads the page" do
      visit '/'
      page.should have_content "#{@user.login}"
      page.should have_content "Share. Manage. Preserve."
      page.status_code.should == 200
    end
  end

  context "when there are only a lot of groups" do
    before {
      add_groups_to_user(100)
    }
    it "loads the page" do
      visit '/'
      page.should have_content "#{@user.login}"
      page.should have_content "Share. Manage. Preserve."
      page.status_code.should == 200
    end
  end

  def add_groups_to_user(number_of_groups)
    group_list_array = []
    (0..number_of_groups).each do |i|
      group_list_array << "umg/up.dlt.scholarsphere-admin.admin#{i}"
    end
    @user.update_attribute(:group_list, group_list_array.join(';?;'))
    # groups_last_update can't be nil, otherwise @user.groups will be []
    # (see User.rb (def groups) )
    @user.update_attribute(:groups_last_update, Time.now)
    @user.save!
  end
end
