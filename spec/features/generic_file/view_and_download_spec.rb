# This file is a Work in Progress

require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Generic File viewing and downloading:', :type => :feature do

  let(:current_user) { create :user }
  let!(:file_1) { create_file current_user, { title: 'File 1' } }
  let!(:file_2) do
    create_file current_user, { title: 'File 2',
        creator: '',
        contributor: '',
        tag: '',
        subject: '',
        language: '',
        based_near: '',
        publisher: '',
        rights: '',
        read_groups: []}
  end

  context "generic user" do
    before do
      sign_in_as current_user
      visit '/dashboard/files'
      expect(page).to have_css '.active a', text:"Files"
      db_item_title(file_1).click
    end

    context 'When viewing a file' do

      specify "I see all the correct information" do
        # "I can see the file's page" do
        expect(page.status_code).to eq(200)
        expect(page).to have_content file_1.title.first

        # 'I can not feature' do
        expect(page).not_to have_link "Feature"

        # 'I should see the visibility link' do
        within(".visibility-link span") do
          expect(page).to have_content("Open Access")
        end

        # 'I should see the breadcrumb trail' do
        expect(page).to have_link("My Dashboard")
        expect(page).to have_link("My Files")

        # 'I can see the link for all the linkable items' do
        expect(page).to have_link 'http://example.org/TheDescriptionLink/'
        expect(page).to have_link file_1.related_url.first

        # 'I can see the link for creator and it filters correctly' do
        test_link file_1.creator.first
        visit "/files/#{file_1.id}"

        # 'I can see the link for contributor and it filters correctly' do
        test_link file_1.contributor.first
        visit "/files/#{file_1.id}"

        # 'I can see the link for publisher and it filters correctly' do
        test_link file_1.publisher.first
        visit "/files/#{file_1.id}"

        # 'I can see the link for subject and it filters correctly' do
        test_link file_1.subject.first
        visit "/files/#{file_1.id}"

        # 'I can see the link for language and it filters correctly' do
        test_link file_1.language.first
        visit "/files/#{file_1.id}"

        # 'I can see the link for based_near and it filters correctly' do
        test_link file_1.based_near.first
        visit "/files/#{file_1.id}"

        # 'I can see the link for a tag and it filters correctly' do
        test_link file_1.tag.first
        visit "/files/#{file_1.id}"

        # 'I can see the link for rights and it filters correctly' do
        test_link Sufia.config.cc_licenses_reverse[file_1.rights.first]
      end


      specify 'I can download an Endnote version of the file' do
        click_link 'EndNote'
        expect(page.response_headers['Content-Type']).to eq('application/x-endnote-refer; charset=utf-8')
      end

      specify 'I can see the Mendeley modal' do
        skip 'This does not appear to be functioning properly'
        click_link 'Mendeley'
        expect(page).to have_css('.modal-header')
      end

      specify 'I can see the Zotero modal' do
        skip 'This does not appear to be functioning properly'
        click_link 'Zotero'
        expect(page).to have_css('.modal-header')
      end

    end

    context "administrator user" do

      let(:admin_user) { create :administrator }
      let!(:public_file) { create_file admin_user, { title: 'File 3' } }
      let!(:private_file) { create_file admin_user, { title: 'File 4', read_groups: []}}

      before do
        sign_in_as admin_user
        visit '/dashboard/files'
      end

      context 'When viewing a public file' do
        before do
          db_item_title(public_file).click
        end

        specify 'I can feature' do
          expect(page).to have_link "Feature"
        end
      end

      context 'When viewing a private file' do
        before do
          db_item_title(private_file).click
        end

        specify 'I can not feature' do
          expect(page).not_to have_link "Feature"
        end
      end
    end

  end

  context 'When downloading a file' do

  end

  def test_link link_name
    expect(page).to have_link link_name
    click_on link_name
    expect(page).to have_content file_1.title.first
    expect(page).not_to have_content file_2.title.first
  end

end
