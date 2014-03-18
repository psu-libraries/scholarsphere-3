require_relative './feature_spec_helper'

# This authentication strategy will automatically succeed for the user that was
# assigned to the `user` class variable.
class StubbedAuthenticationStrategy < ::Devise::Strategies::Base

  # Use this method to set the user that should be authenticated.
  def self.user=(user)
    @@user = user
  end

  # We're a fake authentication strategy; we always succeed.
  def authenticate!
    success!(@@user)
  end

  # Called if the user doesn't already have a rails session cookie
  def valid?
    true
  end

end

# Stub authentication by default. If you do *not* want this to happen, then add
# `stub_authentication: false` to your examples/blocks.
RSpec.configure do |config|
  config.before(:each) do
    unless example.metadata[:stub_authentication] == false
      Warden::Strategies.add(:http_header_authenticatable, StubbedAuthenticationStrategy)
    end
  end

  config.after(:each) do
    unless example.metadata[:stub_authentication] == false
      Warden::Strategies.add(:http_header_authenticatable, Devise::Strategies::HttpHeaderAuthenticatable)
    end
  end
end

def sign_in_as(user)
  StubbedAuthenticationStrategy.user = user
end

describe "Visting the home page" do

  context "when logged in as a curator" do
    let(:current_user) { FactoryGirl.create(:curator) }

    before do
      sign_in_as current_user
    end

    context "when we do not belong to any groups" do
      before do
        visit '/'
      end
      it "loads the page successfully" do
        page.should have_content 'What is ScholarSphere?'
      end
    end

    context "when we belong to a couple of groups" do
      before do
        add_groups_to_current_user 2
        visit '/'
      end
      it "loads the page successfully" do
        page.should have_content 'What is ScholarSphere?'
      end
      it "shows that I'm logged in" do
        page.should have_content current_user.login
      end
    end

    context "when we belong to a lot of groups" do
      before do
        add_groups_to_current_user 5 # See issue #17
        visit '/'
      end
      it "loads the page successfully" do
        page.should have_content 'What is ScholarSphere?'
      end
      it "shows that I'm logged in" do
        page.should have_content current_user.login
      end
    end
  end

  def add_groups_to_current_user(number_of_groups)
    group_list_array = []
    (0..number_of_groups).each do |i|
      group_list_array << "umg/up.dlt.scholarsphere-admin.admin#{i}"
    end
    current_user.update_attribute(:group_list, group_list_array.join(';?;'))
    # groups_last_update can't be nil, otherwise @user.groups will be []
    # (see User.rb (def groups) )
    current_user.update_attribute(:groups_last_update, Time.now)
    current_user.save!
  end

end