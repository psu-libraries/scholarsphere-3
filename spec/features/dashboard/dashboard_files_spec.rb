require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Files', :type => :feature do

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
      expect(page).to have_content("My Files")
      expect(page).to have_selector("h1.sr-only", text: "Files listing")
      within('#sidebar') do
        expect(page).to have_content("Upload")
        expect(page).to have_content("Create Collection")
      end
      # Additional metadata about the file is hidden
      expect(page).not_to have_content "Edit Access"
      expect(page).not_to have_content "little_file.txt_creator"

      # A return controller is specified
      expect(page).to have_css("input#return_controller", visible: false)

      # Clicking + displays additional metadata about that file
      within("#documents") do
        first('i.glyphicon-chevron-right').click
      end
      expect(page).to have_content "little_file.txt_creator"
      expect(page).to have_content "Edit Access"

      db_item_actions_toggle(file).click
      click_link 'Edit File'
      expect(page).to have_content "Edit #{filename}"

      # Clicking the Visibility link loads the edit permissions page
      # The link is not visible in poltergeist unless we resize
      # the page (1440w x 1200h). Somehow using .trigger gets around
      # this issue though.
      go_to_dashboard_files
      db_visibility_link(file).trigger('click')
      expect(page).to have_content 'Permissions'
      expect(page).to have_content 'Visibility'
      expect(page).to have_content 'Share With'

      # Clicking Transfer Ownership of File loads the transfer ownership page
      go_to_dashboard_files
      db_item_actions_toggle(file).click
      click_link 'Transfer Ownership of File'
      expect(page).to have_content "Transfer ownership of \"#{filename}\""
    end

    #specify 'Clicking the Visibility link loads the edit permissions page' do
    #end

    #specify 'Additional metadata about the file is hidden' do
    #end

    #specify 'Clicking + displays additional metadata about that file' do
    #  first('i.glyphicon-chevron-right').click
    #  expect(page).to have_content "plain (Plain text)JPG"
    #  expect(page).to have_content "little_file.txt_creator"
    #end

    #specify 'Clicking Edit File goes directly to the metadata edit page' do
    #  db_item_actions_toggle(file).click
    #  click_link 'Edit File'
    #  expect(page).to have_content "Edit #{filename}"
    #end

    context 'When I highlight it' do
      before do
        db_item_actions_toggle(file).click
        click_link 'Highlight File on Profile'
        db_item_actions_toggle(file).click
        expect(page).to have_content "Unhighlight File"
        db_item_actions_toggle(file).trigger('click')
      end
      specify 'It is highlighted' do
        #It is highlighted on my profile
        visit "/users/#{current_user.login}"
        expect(page).to have_css '.active a', text:"Contributions"
        within '#contributions' do
          expect(page).to have_link "#{file.filename.first}"
        end

        #It is displayed on my highlights
        go_to_dashboard_highlights
        within '#documents' do
          expect(page).to have_link "#{file.filename.first}"
        end
      end

      #specify 'It is displayed on my highlights' do
      #end
    end

    #specify 'Clicking Transfer Ownership of File loads the transfer ownership page' do
    #  db_item_actions_toggle(file).click
    #  click_link 'Transfer Ownership of File'
    #  expect(page).to have_content "Transfer ownership of \"#{filename}\""
    #end

    describe 'The Single-Use Link:' do
      skip 'Places the link on the clipboard'
      skip 'The first visit displays the file data'
      skip 'Subsequent visits fail to load the page'
    end
  end

  let(:conn) { ActiveFedora::SolrService.instance.conn }

  context 'with more than 10 files:' do
    before do
      create_files(current_user, 10)
      visit '/dashboard/files'
    end

    after do
      10.times do |t|
        conn.delete_by_id "199#{t}"
      end
      conn.commit
    end

    describe 'Pagination:' do
      specify 'The files should be listed on multiple pages' do
        expect(page).to have_css('.pagination')

        #Increasing Show per page beyond my current number of files and I should not see a page
        expect(GenericFile.count).to eq(11)
        select('20', :from => 'per_page')
        find_button('Refresh').click
        expect(page).not_to have_css('.pager')
      end
    end

    describe 'Search:' do
      it "shows the correct results" do
        # When I search by partial title it does not display any results
        search_my_files_by_term( 'title')
        expect(page).to have_content 'You searched for: title'
        page_should_not_list_any_files

        # When I search by title using exact words it displays the correct results
        search_my_files_by_term( file.title.first )
        expect(page).to have_content "You searched for: #{file.title.first}"
        page_should_only_list file

        # To Do resource type does not seem to be searchable
        ## When I search by Resource Type it displays the correct results
        #search_my_files_by_term( file.resource_type )
        #expect(page).to have_content "You searched for: #{file.resource_type}"
        #page_should_only_list file

        #When I search by Keywords it displays the correct results
        search_my_files_by_term( file.tag.first )
        expect(page).to have_content "You searched for: #{file.tag.first}"
        page_should_only_list file

        # allows me to remove constraints
        find('span.glyphicon-remove').click
        expect(page).not_to have_content "You searched for:"

        # When I search by Creator it displays the correct results
        search_my_files_by_term( file.creator )
        expect(page).to have_content "You searched for: #{file.creator}"
        page_should_only_list file


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
            #open facet
            click_link(facet)
            expect(page).to have_content(value, wait: Capybara.default_wait_time*2)

            # for some reason the page needs to settle before we can click the next link in the list
            sleep(1.second)
          end
        end
      end
    end

    describe 'Sorting:' do
      specify 'Items are sorted correctly' do
        find('#sort').find(:xpath, 'option[4]').select_option
        click_button("Refresh")
        expect(page).to have_content(file.title.first)
        find('#sort').find(:xpath, 'option[5]').select_option
        click_button("Refresh")
        expect(page).to have_content(file.title.first)
      end
    end

  end

  context "Many files (more than max_batch, which is currently set to 80)" do
    before do
      create_files(current_user, 90)
      visit '/dashboard/files'
    end

    after do
      90.times do |t|
        conn.delete_by_id "199#{t}"
      end
      conn.commit
    end

    it "allows pagination and sorting to be toggeled" do
      select('100', :from => 'per_page')
      find_button('Refresh').click
      first('input.batch_document_selector').click
      within (".batch-info") do
        expect(page).to have_content "Add to Collection"
        expect(page).not_to have_content "Sort By"
      end
      first('input.batch_document_selector').click
      within (".batch-info") do
        expect(page).to have_content "Sort By"
        expect(page).not_to have_content "Add to Collection"
      end

    end
  end

    def search_my_files_by_term( term)
    within('#search-form-header') do
      expect(page).to have_content("My Files")
      fill_in('search-field-header', with: term)
      click_button("Go")
    end
  end


  let (:title_field) {Solrizer.solr_name("desc_metadata__title", :stored_searchable, type: :string)}
  let (:resp) {ActiveFedora::SolrService.instance.conn.get "select", params:{fl:['id',title_field]}}
  def page_should_only_list file
    expect(page).to have_selector('li.active', text:"Files")
    expect(page).to have_content file.title.first
    resp["response"]["docs"].each do |gf|
      title = gf[title_field].first
      expect(page).not_to have_content title  unless title == file.title.first
    end
  end

  def page_should_not_list_any_files
    resp["response"]["docs"].each do |gf|
      expect(page).not_to have_content  gf[title_field].first
    end
  end

  def check_facet_category id, value
    within id do
      within '.slide-list' do
        expect(page).to have_content value
      end
    end
  end

  def create_files(user, number_of_files)
    number_of_files.times do |t|
      conn.add  id: "199#{t}", Solrizer.solr_name('depositor', :stored_searchable) => user.login, "has_model_ssim"=>"info:fedora/afmodel:GenericFile",
                Solrizer.solr_name("desc_metadata__title", :stored_searchable, type: :string) => ["title_#{t}"],
                "depositor_ssim" => user.login, "edit_access_person_ssim" =>user.login,
                Solrizer.solr_name("desc_metadata__resource_type", :facetable) => "Video",
                Solrizer.solr_name("desc_metadata__creator", :facetable) => "Creator1",
                Solrizer.solr_name("desc_metadata__tag", :facetable) =>  "Keyword1",
                Solrizer.solr_name("desc_metadata__subject", :facetable) => "Subject1",
                Solrizer.solr_name("desc_metadata__language", :facetable) => "Language1",
                Solrizer.solr_name("desc_metadata__based_near", :facetable) => "Location1",
                Solrizer.solr_name("desc_metadata__publisher", :facetable) => "Publisher1",
                Solrizer.solr_name("file_format", :facetable) => "plain ()"
    end
    conn.commit
  end
end
