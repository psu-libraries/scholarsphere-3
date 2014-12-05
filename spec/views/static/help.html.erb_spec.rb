require 'spec_helper'

describe 'static/help.html.erb', :type => :view do

  it "should show the static page" do
    render
    expect(rendered).to match /Frequently Asked Questions/

  end
end
