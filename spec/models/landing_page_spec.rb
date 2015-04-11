require 'spec_helper'

describe LandingPage, type: :model do
  let (:lp) { LandingPage.new }

  context "with a valid email" do
    subject do
      lp.email = "test@email.com"
      lp.first_name = "test name"
      return lp
    end

    it "should send to configured email" do
      expect(subject.headers[:to]).to eq(ScholarSphere::Application.config.landing_email)
      expect(subject.headers[:from]).to eq(ScholarSphere::Application.config.landing_from_email)
    end

    it "should include the name and email" do
      expect(subject.headers[:subject]).to include(lp.email)
      expect(subject.headers[:subject]).to include(lp.first_name)
    end
  end

  context "with an incomplete email" do
    subject do
      lp.email = "ashjasfjkhalf"
      lp.valid?
    end
    it { is_expected.to be false }
  end
  context "with an correct email" do
    subject do
      lp.email = "ashjasfjkhalf@email.com"
      lp.valid?
    end
    it { is_expected.to be true }
  end

end
