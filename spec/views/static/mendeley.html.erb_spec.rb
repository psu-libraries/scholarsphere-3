require 'spec_helper'

describe 'static/mendeley.html.erb', type: :view do

  it "should show the static page" do
    render
    expect(rendered).to match /Export to Mendeley/

  end
end
