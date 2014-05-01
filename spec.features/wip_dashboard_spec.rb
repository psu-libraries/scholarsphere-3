# This file is a Work in Progress

require_relative './feature_spec_helper'

describe 'Dashboard:' do

  let(:current_user) { create :user }
  let(:title) { 'Test Collection Title' }
  let(:creator) { 'Test Creator Name' }
  let(:description) { 'Description for our test collection.' }

  # before do
  #   sign_in_as current_user
  #   upload_generic_file 'world.png'
  #   check 'check_all'
  #   click_button 'Add to Collection'
  #   db_create_populated_collection_button.click
  #   create_collection title, creator, description
  # end

  describe 'For an item in my list' do
    specify 'Clicking the Visibility link loads the edit permissions page'
    specify 'Clicking + displays additional metadata about that file'
    specify 'Clicking Edit File goes directly to the metadata edit page'
    specify 'Clicking Download File downloads the file'
    specify 'Clicking Delete File removes the file'
    specify 'Clicking Highlight File will highlight that file on my profile'
    specify 'Clicking Transfer Ownership of File loads the transfer ownership page'
    describe 'The Single-Use Link:' do
      pending 'Places the link on the clipboard'
      pending 'The first visit displays the file data'
      pending 'Subsequent visits fail to load the page'
    end
  end

  describe 'Pagination:' do
    context 'Given I have uploaded 15 files' do
      specify 'The files are listed on 2 pages'
      specify 'Changing Show per page to 20 lists all the files on one page'
    end
  end

  describe 'Search:' do
    specify 'Searching by partial titles does not display any results'
    specify 'Searching with exact words displays the correct results'
    specify 'Searching by Resource Type displays the correct results'
    specify 'Searching by Keywords displays the correct results'
    specify 'Searching by Creator displays the correct results'
  end

  describe 'Facets:' do
    specify 'Displays the correct totals for each type'
  end

  describe 'Sorting:' do
    specify 'Items are sorted correctly'
  end

  describe 'Thumbnails:' do
    it 'shows image thumbnail'
   #  allow_any_instance_of(SolrDocument).to receive(:image?).and_return(true)
   #  go_to_dashboard
   #  page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(@gf1.noid, {datastream_id: 'thumbnail'})}']")
   #end
    it 'shows pdf thumbnail'
   #  allow_any_instance_of(SolrDocument).to receive(:pdf?).and_return(true)
   #  go_to_dashboard
   #  page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(@gf1.noid, {datastream_id: 'thumbnail'})}']")
   #end
    it 'shows video thumbnail'
   #  allow_any_instance_of(SolrDocument).to receive(:video?).and_return(true)
   #  go_to_dashboard
   #  page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(@gf1.noid, {datastream_id: 'thumbnail'})}']")
   #end
    it 'shows audio thumbnail'
   #  allow_any_instance_of(SolrDocument).to receive(:audio?).and_return(true)
   #  go_to_dashboard
   #  page.should have_css('img[src*="/assets/audio.png"]')
   #end
    it 'shows default thumbnail'
   #  go_to_dashboard
   #  page.should have_css('img[src*="/assets/default.png"]')
   #end
  end
end
