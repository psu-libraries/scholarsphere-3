require_relative '../feature_spec_helper'

describe 'Generic File Thumbnail Creation:' do
  let!(:current_user) { create :user }
  let(:generic_filename) { 'small_file.txt' }

  before do
    sign_in_as current_user
    upload_generic_file generic_filename
  end

  let(:file) { find_file_by_title "small_file.txt" }

  context 'When I upload an image' do
    before do
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return('image/png')
      visit(current_path)
    end

    specify "I can see the image thumbnail" do
      page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(file.noid, {datastream_id: 'thumbnail'})}']")
    end
  end

  context 'When I upload a PDF' do
    before do
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return('application/pdf')
      visit(current_path)
    end

    specify "I can see the pdf thumbnail" do
      page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(file.noid, {datastream_id: 'thumbnail'})}']")
    end
  end

  context 'When I upload a video' do
    before do
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return('video/mpeg')
      visit(current_path)
    end

    specify "I can see the video thumbnail" do
      page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(file.noid, {datastream_id: 'thumbnail'})}']")
    end
  end

  context 'When I upload an audio file' do
    before do
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return('audio/mp3')
      visit(current_path)
    end

    specify "I can see the audio thumbnail" do
      page.should have_css("img[src*='/assets/audio.png']")
    end
  end

  context 'When I upload a generic file' do
    before do
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return('other')
      visit(current_path)
    end
    specify "I can see the default thumbnail" do
      page.should have_css("img[src*='/assets/default.png']")
    end
  end

end