# frozen_string_literal: true
require 'rails_helper'

describe 'admin/stats/_export_link.html.erb' do
  let(:href) { '/admin/stats/export' }

  before do
    render
  end

  it 'creates and export link' do
    expect(rendered).to have_link('Export File Metadata', href: href)
  end
end
