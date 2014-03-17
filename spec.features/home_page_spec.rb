require_relative './feature_spec_helper'

describe "Visting the home page" do
  it "loads the page when there are no groups" do
    visit '/'
    page.should have_content 'What is ScholarSphere?'
  end
end