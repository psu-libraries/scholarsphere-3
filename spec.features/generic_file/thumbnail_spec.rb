require_relative '../feature_spec_helper'

describe 'Generic File Thumbnail Creation:' do
  let(:current_user) { create :user }
  let(:image_filename) { 'world.png' }
  let(:pdf_filename) { 'scholarsphere_test4.pdf' }
  let(:generic_filename) { 'small_file.txt' }

  before do
    sign_in_as current_user
  end

  let(:image) { find_file_by_title "world.png" }
  context 'When I upload an image' do
    before do
      upload_generic_file image_filename
      visit '/dashboard'
    end

    specify "I can see the image thumbnail" do
      page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(image.noid, {datastream_id: 'thumbnail'})}']")
    end
  end

  let(:pdf) { find_file_by_title "scholarsphere_test4.pdf" }
  context 'When I upload a PDF' do
    before do
      upload_generic_file pdf_filename
      visit '/dashboard'
    end

    specify "I can see the pdf thumbnail" do
      page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(pdf.noid, {datastream_id: 'thumbnail'})}']")
    end
  end

  let(:file) { find_file_by_title "small_file.txt" }
  context 'When I upload a video' do
    before do
      upload_generic_file generic_filename
      allow_any_instance_of(SolrDocument).to receive(:video?).and_return(true)
      visit '/dashboard'
    end

    specify "I can see the video thumbnail" do
      page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(file.noid, {datastream_id: 'thumbnail'})}']")
    end
  end

  context 'When I upload an audio file' do
    before do
      upload_generic_file generic_filename
      allow_any_instance_of(SolrDocument).to receive(:audio?).and_return(true)
      visit '/dashboard'
    end

    specify "I can see the audio thumbnail" do
      page.should have_css("img[src*='/assets/audio.png']")
    end
  end

  context 'When I upload a generic file' do
    before do
      upload_generic_file generic_filename
      visit '/dashboard'
    end
    specify "I can see the default thumbnail" do
      page.should have_css("img[src*='/assets/default.png']")
    end
  end

end