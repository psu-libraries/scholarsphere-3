# This file is a Work in Progress

require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Generic File viewing and downloading:' do

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

  before do
    sign_in_as current_user
    visit '/dashboard'
    db_item_title(file_1).click
  end

  context 'When viewing a file' do

    specify "I can see the file's page" do
      page.status_code.should == 200
      page.should have_content file_1.title.first
    end

    specify 'I can see the link for creator and it filters correctly' do
      test_link file_1.creator.first
    end

    specify 'I can see the link for contributor and it filters correctly' do
      test_link file_1.contributor.first
    end

    specify 'I can see the link for publisher and it filters correctly' do
      test_link file_1.publisher.first
    end

    specify 'I can see the link for subject and it filters correctly' do
      test_link file_1.subject.first
    end

    specify 'I can see the link for language and it filters correctly' do
      test_link file_1.language.first
    end

    specify 'I can see the link for based_near and it filters correctly' do
      test_link file_1.based_near.first
    end

    specify 'I can see the link for a tag and it filters correctly' do
      test_link file_1.tag.first
    end

    specify 'I can see the link for rights and it filters correctly' do
      test_link file_1.rights.first
    end

    specify 'I can see the link for all the linkable items' do
      page.should have_link 'http://example.org/TheDescriptionLink/'
      page.should have_link file_1.related_url.first
    end

    specify 'I can download an Endnote version of the file' do
      click_link 'EndNote'
      page.response_headers['Content-Type'].should == 'application/x-endnote-refer; charset=utf-8'
    end

    specify 'I can see the Mendeley modal' do
      pending 'This does not appear to be functioning properly'
      click_link 'Mendeley'
      page.should have_css('.modal-header')
    end

    specify 'I can see the Zotero modal' do
      pending 'This does not appear to be functioning properly'
      click_link 'Zotero'
      page.should have_css('.modal-header')
    end

  end

  context 'When downloading a file' do

  end

  def test_link link_name
    page.should have_link link_name
    click_on link_name
    page.should have_content file_1.title.first
    page.should_not have_content file_2.title.first
  end

end