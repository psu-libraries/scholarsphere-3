# frozen_string_literal: true
require 'spec_helper'

describe 'static/zotero.html.erb', type: :view do
  it "shows the static page" do
    render
    expect(rendered).to match(/Export to Zotero/)
  end
end
