# This file is a Work in Progress


require_relative './feature_spec_helper'

describe 'Dashboard:' do

  describe 'view_dashboard' do

    let(:current_user) { create :user }

    def create_collection
    end
    before do
      sign_in_as current_user
      upload_generic_file 'world.png'
      create_collection
    end

    let (:gf1) { GenericFile.last }

    before (:all) do
      user_key = 'jilluser'
      @collection = Collection.new title: 'collection title'
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata user_key
      @collection.save!
      @gf1 =  GenericFile.new title: 'file title', resource_type: 'Video'
      @gf1.apply_depositor_metadata user_key
      @gf1.save!
    end


    describe 'visit dashboard' do

      it 'should visit dashboard' do
        go_to_dashboard
        page.should have_content 'My Dashboard'
        page.should have_content @gf1.title.first
        page.should have_content @collection.title
        page.should have_content @collection.description
      end

      it 'shows image thumbnail' do
        allow_any_instance_of(SolrDocument).to receive(:image?).and_return(true)
        go_to_dashboard
        page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(@gf1.noid, {datastream_id: 'thumbnail'})}']")
      end
      it 'shows pdf thumbnail' do
        allow_any_instance_of(SolrDocument).to receive(:pdf?).and_return(true)
        go_to_dashboard
        page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(@gf1.noid, {datastream_id: 'thumbnail'})}']")
      end
      it 'shows video thumbnail' do
        allow_any_instance_of(SolrDocument).to receive(:video?).and_return(true)
        go_to_dashboard
        page.should have_css("img[src*='#{Sufia::Engine.routes.url_helpers.download_path(@gf1.noid, {datastream_id: 'thumbnail'})}']")
      end
      it 'shows audio thumbnail' do
        allow_any_instance_of(SolrDocument).to receive(:audio?).and_return(true)
        go_to_dashboard
        page.should have_css('img[src*="/assets/audio.png"]')
      end
      it 'shows default thumbnail' do
        go_to_dashboard
        page.should have_css('img[src*="/assets/default.png"]')
      end
    end

    def go_to_dashboard
      visit '/'
      click_link 'my dashboard'
    end
  end
end
