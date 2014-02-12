require 'spec_helper'

describe 'static/zotero.html.erb' do

  it "should show the static page" do
    render
    expect(rendered).to match /Export to Zotero/

  end
end
