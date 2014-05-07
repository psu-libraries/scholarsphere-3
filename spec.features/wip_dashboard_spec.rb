# This file is a Work in Progress

require_relative './feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard:' do

  let(:current_user) { create :user }

  before do
    sign_in_as current_user
    upload_generic_file 'world.png'
  end

  let(:file) { GenericFile.find(Solrizer.solr_name("desc_metadata__title")=>"world.png").first }
  let(:filename) { file.filename.first }

  describe 'For a file in my list:' do

    pending 'Clicking the Visibility link loads the edit permissions page' do
      db_visibility_link(file).click
      page.should have_content 'Permissions'
      page.should have_content 'Visibility'
      page.should have_content 'Share With'
    end

    specify 'Clicking + displays additional metadata about that file'

    specify 'Clicking Edit File goes directly to the metadata edit page' do
      db_item_actions_toggle(file).click
      click_link 'Edit File'
      page.should have_content "Edit #{filename}"
    end

    context 'When I highlight it' do
      before do
        db_item_actions_toggle(file).click
        click_link 'Highlight File on Profile'
      end
      specify 'It is highlighted on my profile' do
        visit "/users/#{current_user.login}"
        within '#contributions' do
          page.should have_link "#{file.filename.first}"
        end
      end
    end

    specify 'Clicking Transfer Ownership of File loads the transfer ownership page' do
      db_item_actions_toggle(file).click
      click_link 'Transfer Ownership of File'
      page.should have_content "Transfer ownership of \"#{filename}\""
    end

    describe 'The Single-Use Link:' do
      pending 'Places the link on the clipboard'
      pending 'The first visit displays the file data'
      pending 'Subsequent visits fail to load the page'
    end
  end

  describe 'When I have more than 10 files:' do
    before do
      create_files(current_user, 10)
      visit '/dashboard'
    end

    describe 'Pagination:' do
      specify 'The files should be listed on multiple pages' do
        page.should have_css('.pager')
      end
      context 'Increasing Show per page beyond my current number of files' do
        before do
          # current_user should only have 11 files
          GenericFile.count.should == 11
          select('20', :from => 'per_page')
          find_button('Refresh').click
        end
        specify 'lists all the files on one page' do
          page.should_not have_css('.pager')
        end
      end
    end

    describe 'Search:' do
      context 'When I search by partial title' do
        before do
          fill_in 'Search My Dashboard', with: 'title'
          find_button('dashboard_submit').click
          page.should have_content 'You searched for: title'
        end
        it 'Does not display any results' do
          page_should_not_list_any_files
        end
      end

      context 'When I search by title using exact words' do
        before do
          fill_in 'Search My Dashboard', with: file.title.first
          find_button('dashboard_submit').click
          page.should have_content "You searched for: #{file.title.first}"
        end
        it 'Displays the correct results' do
          page_should_only_list file
        end
      end

      context 'When I search by Resource Type' do
        before do
          fill_in 'Search My Dashboard', with: 'png'
          find_button('dashboard_submit').click
          page.should have_content 'You searched for: png'
        end
        it 'Displays the correct results' do
          page_should_only_list file
        end
      end

      context 'When I search by Keywords' do
        before do
          fill_in 'Search My Dashboard', with: file.tag
          find_button('dashboard_submit').click
          page.should have_content "You searched for: #{file.tag}"
        end
        it 'Displays the correct results' do
          page_should_only_list file
        end
      end

      context 'When I search by Creator' do
        before do
          fill_in 'Search My Dashboard', with: file.creator
          find_button('dashboard_submit').click
          page.should have_content "You searched for: #{file.creator}"
        end
        it 'Displays the correct results' do
          page_should_only_list file
        end
      end
    end

    describe 'Facets:' do
      # Still need to test Collection
      {
        'Resource_Type' => 'Video (10)',
        'Creator'       => 'Creator1 (10)',
        'Keyword'       => 'Keyword1 (10)',
        'Subject'       => 'Subject1 (10)',
        'Language'      => 'Language1 (10)',
        'Location'      => 'Location1 (10)',
        'Publisher'     => 'Publisher1 (10)',
        'File_Format'   => 'plain () (10)'
      }.each do |facet, value|
        specify "Displays the correct totals for #{facet}" do
          db_facet_category_toggle("#collapse_#{facet}_db").click
          check_facet_category "#collapse_#{facet}_db", value
        end
      end 
    end
  end

  describe 'Sorting:' do
    specify 'Items are sorted correctly'
  end

  def page_should_only_list file
    page.should have_content file.title.first
    GenericFile.all.each do |gf|
      page.should_not have_content gf.title.first unless gf.title.first == file.title.first
    end
  end

  def page_should_not_list_any_files
    GenericFile.all.each do |gf|
      page.should_not have_content gf.title.first
    end
  end

  def check_facet_category id, value
    within id do
      within '.slide-list' do
        page.should have_content value
      end
    end
  end

  def create_files(user, number_of_files)
    (1..number_of_files).each do |x|
      GenericFile.new.tap do |f|
        f.title = "title_#{x}"
        f.apply_depositor_metadata(user.login)
        f.resource_type = 'Video'
        #Collection
        f.creator = 'Creator1'
        f.tag = 'Keyword1'
        f.subject = 'Subject1'
        f.language = 'Language1'
        f.based_near = 'Location1'
        f.publisher = 'Publisher1'
        f.mime_type = 'text/plain'
        f.save!
      end
    end
  end
end
