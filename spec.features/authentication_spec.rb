require_relative './feature_spec_helper'

describe "Site authentication" do
  context "When I'm not signed in" do
    describe "And I click 'Login' from the home page" do
      specify "I should be redirected to the appropriate central login page" do
        visit '/'
        click_on 'Login'
        current_url.should == centralized_login_url
      end
    end
    describe "And I attempt to visit a restricted page on the site" do
      specify "The restricted path should be included in my redirected url" do
        visit '/dashboard'
        current_url.should == centralized_login_url + "dashboard"
      end
    end
  end

  def centralized_login_url
    Sufia::Engine.config.login_url
  end
end
