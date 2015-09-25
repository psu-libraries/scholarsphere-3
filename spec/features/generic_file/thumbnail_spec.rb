require_relative '../feature_spec_helper'

describe 'Generic File Thumbnail Creation:', type: :feature do
  let!(:current_user) { create :user }
  let!(:file) { create_file current_user, title: 'little_file.txt' }
  let(:thumbnail_path) { Sufia::Engine.routes.url_helpers.download_path(file, file: 'thumbnail') }

  before do
    sign_in_as current_user
    allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return(mime_type)
    go_to_dashboard_files
  end

  context 'When I upload an image' do
    let(:mime_type) { 'image/png' }

    specify "I can see the image thumbnail" do
      expect(page).to have_css("img[src*='#{thumbnail_path}']")
    end
  end

  context 'When I upload a PDF' do
    let(:mime_type) { 'application/pdf' }

    specify "I can see the pdf thumbnail" do
      expect(page).to have_css("img[src*='#{thumbnail_path}']")
    end
  end

  context 'When I upload a video' do
    let(:mime_type) { 'video/mpeg' }

    specify "I can see the video thumbnail" do
      expect(page).to have_css("img[src*='#{thumbnail_path}']")
    end
  end

  context 'When I upload an audio file' do
    let(:mime_type) { 'audio/mp3' }

    specify "I can see the audio thumbnail" do
      expect(page).to have_css("img[src*='/assets/audio.png']")
    end
  end

  context 'When I upload an office document file' do
    let(:mime_type) { 'application/msword' }

    specify "I can see the audio thumbnail" do
      expect(page).to have_css("img[src*='#{thumbnail_path}']")
    end
  end

  context 'When I upload a generic file' do
    let(:mime_type) { 'other' }
    specify "I can see the default thumbnail" do
      expect(page).to have_css("img[src*='/assets/default.png']")
    end
  end
end
