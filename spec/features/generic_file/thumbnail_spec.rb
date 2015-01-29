require_relative '../feature_spec_helper'

describe 'Generic File Thumbnail Creation:', :type => :feature do
  let!(:current_user) { create :user }
  let!(:file) { create_file current_user, {title:'little_file.txt'} }

  before do
    sign_in_as current_user
    go_to_dashboard_files
  end

  context 'When I upload an image' do
    before do
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return('image/png')
      visit(current_path)
    end

    specify "I can see the image thumbnail" do
      expect(page).to have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(file, {datastream_id: 'thumbnail'})}']")
    end
  end

  context 'When I upload a PDF' do
    before do
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return('application/pdf')
      visit(current_path)
    end

    specify "I can see the pdf thumbnail" do
      expect(page).to have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(file, {datastream_id: 'thumbnail'})}']")
    end
  end

  context 'When I upload a video' do
    before do
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return('video/mpeg')
      visit(current_path)
    end

    specify "I can see the video thumbnail" do
      expect(page).to have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(file, {datastream_id: 'thumbnail'})}']")
    end
  end

  context 'When I upload an audio file' do
    before do
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return('audio/mp3')
      visit(current_path)
    end

    specify "I can see the audio thumbnail" do
      expect(page).to have_css("img[src*='/assets/audio.png']")
    end
  end

  context 'When I upload an office document file' do
    before do
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return('application/msword')
      visit(current_path)
    end

    specify "I can see the audio thumbnail" do
      expect(page).to have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(file, {datastream_id: 'thumbnail'})}']")
    end
  end

  context 'When I upload a generic file' do
    before do
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return('other')
      visit(current_path)
    end
    specify "I can see the default thumbnail" do
      expect(page).to have_css("img[src*='/assets/default.png']")
    end
  end

end
