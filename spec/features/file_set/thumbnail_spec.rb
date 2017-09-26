# frozen_string_literal: true

require 'feature_spec_helper'

# Notice that with Sufia 7 we generate thumbnails at the FileSets level
# in a similar way to what we did in Sufia 6 for GenericFiles.
describe 'FileSet Thumbnail Creation:', type: :feature do
  let(:current_user)   { create(:user) }
  let(:file_set)       { work.file_sets.first }
  let(:thumbnail_path) { main_app.download_path(file_set, file: 'thumbnail') }

  before do
    sign_in(current_user)
    visit "/concern/file_sets/#{file_set.id}"
  end

  context 'When FileSet has a thumbnail' do
    let(:work) { create(:public_work_with_png, file_title: ['Some work'], depositor: current_user.login) }

    it 'renders the thumbnail' do
      expect(page).to have_css("img[src*='#{thumbnail_path}']")
    end
  end

  context 'When fileset does not have a thumbnail' do
    let(:work)  { create(:public_work_with_mp3, file_title: ['Some work'], depositor: current_user.login) }

    it 'does not render a thumbnail' do
      expect(page).not_to have_css("img[src*='#{thumbnail_path}']")
    end
  end
end
