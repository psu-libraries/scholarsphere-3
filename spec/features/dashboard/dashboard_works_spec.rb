# frozen_string_literal: true
require 'feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Works', type: :feature do
  let!(:current_user) { create(:user) }

  let!(:file) do
    create(:public_work, :with_complete_metadata,
           depositor: current_user.login,
           title: ['little_file.txt'],
           creator: ['little_file.txt_creator'],
           date_uploaded: DateTime.now + 1.hour
          )
  end

  let(:jill) { create(:jill) }
  let!(:other_collection) do
    create(:collection, title: ['jill collection'], depositor: jill.login)
  end

  before do
    sign_in_with_js(current_user)
    go_to_dashboard_works
  end

  let(:filename) { file.title.first }

  context 'with one work:' do
    specify 'interactions are wired correctly' do
      # tab title and buttons
      expect(page).to have_content("My Works")
      expect(page).to have_selector("h2.sr-only", text: "Works listing")
      expect(page).to have_link("New Work", visible: false) # link is there (even if collapsed)
      expect(page).to have_link("New Collection", visible: false) # link is there (even if collapsed)
      # Additional metadata about the file is hidden
      expect(page).not_to have_content "Edit Access"
      expect(page).not_to have_content file.creator.first

      # A return controller is specified
      expect(page).to have_css("input#return_controller", visible: false)
      # Displays additional metadata about that file
      first('span.glyphicon-chevron-right').click
      expect(page).to have_content file.creator.first
      expect(page).to have_content file.depositor
      expect(page).to have_content "Edit Access"

      db_item_actions_toggle(file).click
      click_link 'Edit Work'
      expect(page).to have_content("Edit Work")
      expect(page).to have_field("generic_work[title][]", with: filename)
      expect(page).to have_content 'Visibility'

      # TODO: This part of the test won't pass until this Sufia
      #       ticket has been closed: https://github.com/projecthydra/sufia/issues/2049
      go_to_dashboard_works
      db_visibility_link(file).trigger('click')
      expect(page).to have_content('Sharing With')

      # Clicking Transfer Ownership of File loads the transfer ownership page
      go_to_dashboard_works
      db_item_actions_toggle(file).click
      click_link 'Transfer Ownership of Work'
      expect(page).to have_content "Transfer ownership of \"#{filename}\""
    end

    context 'When I highlight it' do
      before do
        db_item_actions_toggle(file).click
        click_link 'Highlight Work on Profile'
        db_item_actions_toggle(file).click
        expect(page).to have_content "Unhighlight Work"
        db_item_actions_toggle(file).trigger('click')
      end
      specify 'It is highlighted' do
        # It is highlighted on my profile
        visit "/users/#{current_user.login}\#contributions"
        expect(page).to have_css '.active a', text: "Highlighted"
        within '#contributions' do
          expect(page).to have_link file.title.first
        end

        # It is displayed on my highlights
        go_to_dashboard_highlights
        within '#documents' do
          expect(page).to have_link file.title.first
        end
      end
    end

    # TODO: Feature tests for single-use links
    # describe 'The Single-Use Link:' do
    #   skip 'Places the link on the clipboard'
    #   skip 'The first visit displays the file data'
    #   skip 'Subsequent visits fail to load the page'
    # end
  end

  let(:conn) { ActiveFedora::SolrService.instance.conn }

  context 'with more than 10 works:' do
    before do
      create_works(current_user, 10)
      go_to_dashboard_works
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

        # Increasing Show per page beyond my current number of works and I should not see a page
        expect(GenericWork.count).to eq(11)
        select('20', from: 'per_page')
        find_button('Refresh').click
        expect(page).not_to have_css('.pager')
      end
    end

    describe 'Search:' do
      it "shows the correct results" do
        # When I search by partial title it does not display any results
        search_my_files_by_term('title')
        expect(page).to have_content 'You searched for: title'
        page_should_not_list_any_files

        # When I search by title using exact words it displays the correct results
        search_my_files_by_term(file.title.first)
        expect(page).to have_content "You searched for: #{file.title.first}"
        page_should_only_list file

        # To Do resource type does not seem to be searchable
        ## When I search by Resource Type it displays the correct results
        # search_my_files_by_term( file.resource_type )
        # expect(page).to have_content "You searched for: #{file.resource_type}"
        # page_should_only_list file

        # When I search by Keywords it displays the correct results
        search_my_files_by_term(file.keyword.first)
        expect(page).to have_content "You searched for: #{file.keyword.first}"
        page_should_only_list file

        # allows me to remove constraints
        find('span.glyphicon-remove').click
        expect(page).not_to have_content "You searched for:"

        # When I search by Creator it displays the correct results
        search_my_files_by_term(file.creator.first.to_s)
        expect(page).to have_content "You searched for: #{file.creator.first}"
        page_should_only_list file
      end
    end

    describe 'Facets:' do
      specify "Displays the correct totals for facet" do
        {
          'Resource Type' => 'Video (10)',
          'Creator'       => 'Creator1 (10)',
          'Keyword'       => 'keyword1 (10)',
          'Subject'       => 'Subject1 (10)',
          'Language'      => 'Language1 (10)',
          'Location'      => 'Location1 (10)',
          'Publisher'     => 'Publisher1 (10)',
          'Format'        => 'plain () (10)'
        }.each do |facet, value|
          within("#facets") do
            # open facet
            click_link(facet)
            expect(page).to have_content(value, wait: Capybara.default_max_wait_time * 2)

            # for some reason the page needs to settle before we can click the next link in the list
            sleep(1.second)
          end
        end
      end
    end

    describe 'Sorting:' do
      specify 'Items are sorted correctly' do
        select("date uploaded ▼", from: "sort")
        click_button("Refresh")
        expect(page).to have_content(file.title.first)
        select("date uploaded ▲", from: "sort")
        click_button("Refresh")
        expect(page).not_to have_content(file.title.first)
      end
    end

    context "with collection of other users" do
      it "does not show other user's collection" do
        first('input.batch_document_selector').click
        click_button 'Add to Collection'
        expect(page).to have_css('#collection-list-container')
        expect(page).not_to have_content(other_collection.title)
      end
    end
  end

  context "Many works (more than max_batch, which is currently set to 80)" do
    before do
      create_works(current_user, 90)
      go_to_dashboard_works
    end

    after do
      90.times do |t|
        conn.delete_by_id "199#{t}"
      end
      conn.commit
    end

    it "allows pagination and sorting to be toggeled" do
      select('100', from: 'per_page')
      find_button('Refresh').click
      first('input.batch_document_selector').click
      within(".batch-info") do
        expect(page).to have_content "Add to Collection"
        expect(page).not_to have_content "Sort By"
      end
      first('input.batch_document_selector').click
      within(".batch-info") do
        expect(page).to have_content "Sort By"
        expect(page).not_to have_content "Add to Collection"
      end
    end
  end

  def search_my_files_by_term(term)
    within('#search-form-header') do
      expect(page).to have_content("My Works")
      fill_in('search-field-header', with: term)
      click_button("Go")
    end
  end

  let(:title_field) { Solrizer.solr_name("title", :stored_searchable, type: :string) }
  let(:resp) { ActiveFedora::SolrService.instance.conn.get "select", params: { fl: ['id', title_field] } }
  def page_should_only_list(file)
    expect(page).to have_selector('li.active', text: "My Works")
    expect(page).to have_content file.title.first
    resp["response"]["docs"].each do |gf|
      unless gf[title_field].nil?
        title = gf[title_field].first
        expect(page).not_to have_content title unless title == file.title.first
      end
    end
  end

  def page_should_not_list_any_files
    resp["response"]["docs"].each do |gf|
      unless gf[title_field].nil?
        expect(page).not_to have_content gf[title_field].first
      end
    end
  end

  def check_facet_category(id, value)
    within id do
      within '.slide-list' do
        expect(page).to have_content value
      end
    end
  end

  def create_works(_user, number_of_works)
    number_of_works.times do |t|
      work = build(:public_work, id: "199#{t}",
                                 title: ["Sample Work #{t}"],
                                 date_uploaded: (Time.now - (t + 1).hours),
                                 depositor: current_user.login, resource_type: ["Video"],
                                 creator: ["Creator1"], keyword: ["Keyword1"],
                                 subject: ["Subject1"], language: ["Language1"],
                                 based_near: ["Location1"], publisher: ["Publisher1"])

      # TODO: how to do we set the file format in the objects with build
      hash = work.to_solr
      hash[Solrizer.solr_name("file_format", :facetable)] = "plain ()"
      conn.add hash
    end
    conn.commit
  end
end
