require 'spec_helper'

describe LandingPage do
  let (:lp) { LandingPage.new }

  it "should send to configured email" do
    lp.headers[:to].should == ScholarSphere::Application.config.landing_email
    lp.headers[:from].should == ScholarSphere::Application.config.landing_from_email
  end

  it "should include the name and email" do
    lp.email = "test@email.com"
    lp.first_name = "test name"
    lp.headers[:subject].should include(lp.email)
    lp.headers[:subject].should include(lp.first_name)
  end

  it "should validate email" do
    lp.email = "ashjasfjkhalf"
    lp.valid?.should == false

    lp.email = "ashjasfjkhalf@email.com"
    lp.valid?.should == true
  end

end
