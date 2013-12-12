require 'spec_helper'

describe 'static/help.html.erb' do

  it "should show the static page" do
    render
    expect(rendered).to match /Service Inquiries and Requests/

  end
end
