require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Files' do

  let!(:current_user) { create :user }

  let!(:file) { create_file current_user, { title: 'little_file.txt', creator: 'little_file.txt_creator', resource_type: "stuff" } }

  before do
    sign_in_as current_user
    go_to_dashboard_files
  end

  let(:filename) { file.title.first }

  context 'with one file:' do

    specify 'interactions are wired correctly' do
      #tab title and buttons
      page.should have_content("My Files")
      within('.col-xs-12.col-sm-3') do
        page.should have_content("Upload")
        page.should have_content("Create Collection")
      end
      # Additional metadata about the file is hidden
      page.should_not have_content "Edit Access"
      page.should_not have_content "little_file.txt_creator"

      # Clicking + displays additional metadata about that file
      within("#documents") do
        first('i.glyphicon-chevron-right').click
      end
      page.should have_content "little_file.txt_creator"
      page.should have_content "Edit Access"

      db_item_actions_toggle(file).click
      click_link 'Edit File'
      page.should have_content "Edit #{filename}"

      # Clicking the Visibility link loads the edit permissions page
      # The link is not visible in poltergeist unless we resize
      # the page (1440w x 1200h). Somehow using .trigger gets around
      # this issue though.
      go_to_dashboard_files
      db_visibility_link(file).trigger('click')
      page.should have_content 'Permissions'
      page.should have_content 'Visibility'
      page.should have_content 'Share With'

      # Clicking Transfer Ownership of File loads the transfer ownership page
      go_to_dashboard_files
      db_item_actions_toggle(file).click
      click_link 'Transfer Ownership of File'
      page.should have_content "Transfer ownership of \"#{filename}\""
    end

    #specify 'Clicking the Visibility link loads the edit permissions page' do
    #end

    #specify 'Additional metadata about the file is hidden' do
    #end

    #specify 'Clicking + displays additional metadata about that file' do
    #  first('i.glyphicon-chevron-right').click
    #  page.should have_content "plain (Plain text)JPG"
    #  page.should have_content "little_file.txt_creator"
    #end

    #specify 'Clicking Edit File goes directly to the metadata edit page' do
    #  db_item_actions_toggle(file).click
    #  click_link 'Edit File'
    #  page.should have_content "Edit #{filename}"
    #end

    context 'When I highlight it' do
      before do
        db_item_actions_toggle(file).click
        click_link 'Highlight File on Profile'
        db_item_actions_toggle(file).click
        page.should have_content "Unhighlight File"
        db_item_actions_toggle(file).trigger('click')
      end
      specify 'It is highlighted' do
        #It is highlighted on my profile
        visit "/users/#{current_user.login}"
        page.should have_css '.active a', text:"Contributions"
        within '#contributions' do
          page.should have_link "#{file.filename.first}"
        end

        #It is displayed on my highlights
        go_to_dashboard_highlights
        within '#documents' do
          page.should have_link "#{file.filename.first}"
        end
      end

      #specify 'It is displayed on my highlights' do
      #end
    end

    #specify 'Clicking Transfer Ownership of File loads the transfer ownership page' do
    #  db_item_actions_toggle(file).click
    #  click_link 'Transfer Ownership of File'
    #  page.should have_content "Transfer ownership of \"#{filename}\""
    #end

    describe 'The Single-Use Link:' do
      pending 'Places the link on the clipboard'
      pending 'The first visit displays the file data'
      pending 'Subsequent visits fail to load the page'
    end
  end

  context 'with more than 10 files:' do
    before do
      create_files(current_user, 10)
      visit '/dashboard/files'
    end

    describe 'Pagination:' do
      specify 'The files should be listed on multiple pages' do
        page.should have_css('.pagination')
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
          search_my_files_by_term( 'title')
          page.should have_content 'You searched for: title'
        end
        it 'Does not display any results' do
          page_should_not_list_any_files
        end
      end

      context 'When I search by title using exact words' do
        before do
          search_my_files_by_term( file.title.first )
          page.should have_content "You searched for: #{file.title.first}"
        end
        it 'Displays the correct results' do
          page_should_only_list file
        end
      end

      context 'When I search by Resource Type' do
        before do
          search_my_files_by_term( file.title )
          page.should have_content "You searched for: #{file.title}"
        end
        it 'Displays the correct results' do
          page_should_only_list file
        end
      end

      context 'When I search by Keywords' do
        before do
          search_my_files_by_term( file.tag.first )
          page.should have_content "You searched for: #{file.tag.first}"
        end
        it 'Displays the correct results' do
          page_should_only_list file

          # allows me to remove constraints
          find('span.glyphicon-remove').click
          page.should_not have_content "You searched for:"
        end
      end

      context 'When I search by Creator' do
        before do
          search_my_files_by_term( file.creator )
          page.should have_content "You searched for: #{file.creator}"
        end
        it 'Displays the correct results' do
          page_should_only_list file
        end
      end
    end

    describe 'Facets:' do
      specify "Displays the correct totals for facet" do
        {
          'Resource Type' => 'Video (10)',
          'Creator'       => 'Creator1 (10)',
          'Keyword'       => 'Keyword1 (10)',
          'Subject'       => 'Subject1 (10)',
          'Language'      => 'Language1 (10)',
          'Location'      => 'Location1 (10)',
          'Publisher'     => 'Publisher1 (10)',
          'File Format'   => 'plain () (10)'
        }.each do |facet, value|
          within("#facets") do
            click_link(facet)
            page.should have_content(value)
          end
        end
      end
    end

    describe 'Sorting:' do
      specify 'Items are sorted correctly' do
        find('#sort').find(:xpath, 'option[4]').select_option
        click_button("Refresh")
        page.should have_content(file.title.first)
        find('#sort').find(:xpath, 'option[5]').select_option
        click_button("Refresh")
        page.should have_content(file.title.first)
      end
    end
  end

  def search_my_files_by_term( term)
    within('#search-form-header') do
      page.should have_content("My Files")
      fill_in('search-field-header', with: term)
      click_button("Go")
    end
  end

  def page_should_only_list file
    expect(page).to have_selector('li.active', text:"Files")
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
        f.title = ["title_#{x}"]
        f.apply_depositor_metadata(user.login)
        f.resource_type = ['Video']
        f.creator = ['Creator1']
        f.tag = ['Keyword1']
        f.subject = ['Subject1']
        f.language = ['Language1']
        f.based_near = ['Location1']
        f.publisher = ['Publisher1']
        f.mime_type = 'text/plain'
        f.save!
      end
    end
  end
end
