# frozen_string_literal: true

require 'net/http'
require 'open-uri'

require 'feature_spec_helper'
describe GenericWork, type: :feature do
  let(:filepath) { File.join(fixture_path, 'world.png') }
  let!(:current_user) { create(:user) }
  let!(:work) { create(:public_work_with_png, title: ['Work for testing external files'], depositor: current_user.login) }

  before do
    described_class.all.map(&:update_index)
    FileSet.all.map(&:update_index)
    login_as(current_user)
  end

  it 'displays the contents of the readme' do
    visit(polymorphic_path(work))
    click_on 'Download'
    expect(page.response_headers['Content-Length']).to eq('4218') # size of the image zipped
    expect(page.response_headers['Content-Disposition']).to eq('inline; filename="world.png"')
  end
end
