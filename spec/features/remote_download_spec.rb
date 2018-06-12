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
    sign_in(current_user)
  end

  it 'displays the contents of the readme' do
    visit(polymorphic_path(work))
    click_on 'Download'
    downloaded_file = open("http://localhost:4000/downloads/#{work.file_sets.first.id}").read
    expect(downloaded_file.size).to eq(4219)
  end
end
