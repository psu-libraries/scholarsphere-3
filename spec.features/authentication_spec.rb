require_relative './feature_spec_helper'

describe "Site authentication", stub_authentication: false do
  context "When I'm not signed in" do
    describe "And I click 'Login' from the home page" do
      specify "I should be redirected to the appropriate central login page" do
        visit '/'
        click_on 'Login'
        URI.unescape(current_url).should == Sufia::Engine.config.login_url
      end
    end
    describe "And I attempt to visit a restricted page on the site" do
      specify "The restricted path should be included in my redirected url" do
        visit '/dashboard'
        URI.unescape(current_url).should == Sufia::Engine.config.login_url.chomp("/") + "/dashboard"
      end
    end
  end
end
