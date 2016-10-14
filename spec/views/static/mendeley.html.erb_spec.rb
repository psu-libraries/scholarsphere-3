# frozen_string_literal: true
require 'rails_helper'

describe 'static/mendeley.html.erb', type: :view do
  it "shows the static page" do
    render
    expect(rendered).to match(/Export to Mendeley/)
  end
end
