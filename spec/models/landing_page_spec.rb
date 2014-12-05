require 'spec_helper'

describe LandingPage, :type => :model do
  let (:lp) { LandingPage.new }

  it "should send to configured email" do
    expect(lp.headers[:to]).to eq(ScholarSphere::Application.config.landing_email)
    expect(lp.headers[:from]).to eq(ScholarSphere::Application.config.landing_from_email)
  end

  it "should include the name and email" do
    lp.email = "test@email.com"
    lp.first_name = "test name"
    expect(lp.headers[:subject]).to include(lp.email)
    expect(lp.headers[:subject]).to include(lp.first_name)
  end

  it "should validate email" do
    lp.email = "ashjasfjkhalf"
    expect(lp.valid?).to eq(false)

    lp.email = "ashjasfjkhalf@email.com"
    expect(lp.valid?).to eq(true)
  end

end
