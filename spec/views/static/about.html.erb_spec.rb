require 'spec_helper'

describe 'static/about.html.erb' do

  it "should show the static page" do
    render
    expect(rendered).to match /What is ScholarSphere?/

  end
end
