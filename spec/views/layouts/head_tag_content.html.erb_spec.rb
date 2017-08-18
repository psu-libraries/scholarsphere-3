# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/_head_tag_content.html.erb', type: :view do
  it 'links to a favicon' do
    render
    page = Capybara::Node::Simple.new(rendered)
    expect(page).to have_xpath("//link[@rel='shortcut icon']", visible: false)
  end
end
