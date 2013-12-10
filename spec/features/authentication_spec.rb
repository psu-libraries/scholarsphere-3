require 'spec_helper'

include Warden::Test::Helpers

describe_options = {type: :feature}

describe "login" do
  it "should redirect to central login page" do
    visit "/login"
    URI.unescape(current_url).should == Sufia::Engine.config.login_url
  end
end
describe "when user was redirected from protected url", describe_options do
  it "should pass previous location through to central login page" do
    visit "/dashboard"
    URI.unescape(current_url).should == Sufia::Engine.config.login_url.chomp("/") + "/dashboard"
  end
end