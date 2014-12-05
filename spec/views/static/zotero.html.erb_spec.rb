require 'spec_helper'

describe 'static/zotero.html.erb', :type => :view do

  it "should show the static page" do
    render
    expect(rendered).to match /Export to Zotero/

  end
end
