# frozen_string_literal: true

require 'feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Works', type: :feature, js: true do
  let(:current_user) { create(:user) }
  let(:jill) { create(:jill) }
  let(:work1_creator_name) { 'Work One Creator' }

  let(:creator) { create(:alias, display_name: work1_creator_name,
                                 agent: Agent.new(given_name: 'Work One', sur_name: 'Creator')) }

  let!(:work1) do
    create(:public_work, :with_complete_metadata,
           id: 'dashboard-works-work1',
           depositor: current_user.login,
           title: ['little_file.txt'],
           creators: [creator],
           date_uploaded: DateTime.now + 1.hour)
  end

  let!(:work2) do
    create(:registered_work, id: 'dashboard-works-work2', depositor: current_user.login, title: ['Registered work'])
  end

  before do
    login_as(current_user)
  end

  let(:filename) { work1.title.first }

  context 'with two works' do
    before do
      go_to_dashboard_works
    end

    specify 'interactions are wired correctly' do
      # tab title and buttons
      expect(page).to have_content('My Works')
      expect(page).not_to have_content('Object Type')
      expect(page).to have_selector('h2.sr-only', text: 'Works listing')
      expect(page).to have_link('New Work', visible: false) # link is there (even if collapsed)
      expect(page).to have_link('New Collection', visible: false) # link is there (even if collapsed)

      # Additional metadata about the work1 is hidden
      expect(page).not_to have_content 'Edit Access'
      expect(page).not_to have_content work1_creator_name

      # A return controller is specified
      expect(page).to have_css('input#return_controller', visible: false)

      # Displays visibility information about my works
      within("#document_#{work1.id}") do
        expect(page).to have_selector('span.label-success', text: 'Public')
      end
      within("#document_#{work2.id}") do
        expect(page).to have_selector('span.label-info', text: 'Penn State')
      end

      # Displays additional metadata about that work1
      first('span.glyphicon-chevron-right').click
      expect(page).to have_content work1_creator_name
      expect(page).to have_content work1.depositor
      expect(page).to have_content 'Edit Access'

      db_item_actions_toggle(work1).click
      click_link 'Edit Work'
      expect(page).to have_content('Edit Work')
      expect(page).to have_field('generic_work[title]', with: filename)
      expect(page).to have_content 'Visibility'

      # TODO: This part of the test won't pass until this Sufia
      #       ticket has been closed: https://github.com/projecthydra/sufia/issues/2049
      go_back
      db_visibility_link(work1).click
      expect(page).to have_content('Sharing With')

      # Clicking Transfer Ownership loads the transfer ownership page
      go_back
      db_item_actions_toggle(work1).click
      click_link 'Transfer Ownership of Work'
      expect(page).to have_content "Transfer ownership of \"#{filename}\""
    end

    context 'When I highlight it' do
      before do
        db_item_actions_toggle(work1).click
        click_link 'Highlight Work on Profile'
        db_item_actions_toggle(work1).click
        expect(page).to have_content 'Unhighlight Work'
        db_item_actions_toggle(work1).click
      end
      specify 'It is highlighted' do
        # It is highlighted on my profile
        visit "/users/#{current_user.login}\#contributions"
        expect(page).to have_css '.active a', text: 'Highlighted'
        within '#contributions' do
          expect(page).to have_link work1.title.first
        end

        # It is displayed on my highlights
        go_to_dashboard_highlights
        within '#documents' do
          expect(page).to have_link work1.title.first
        end
      end
    end

    # TODO: Feature tests for single-use links
    # describe 'The Single-Use Link:' do
    #   skip 'Places the link on the clipboard'
    #   skip 'The first visit displays the work1 data'
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

    describe 'Facet: & Search: ' do
      it 'shows the correct results' do
        # It displays the correct totals for facet
        @original_value = Capybara.ignore_hidden_elements
        Capybara.ignore_hidden_elements = false
        {
          'Resource Type' => 'Video (10)',
          'Creator'       => 'Creator1 Jones (10)',
          'Keyword'       => 'keyword1 (10)',
          'Subject'       => 'Subject1 (10)',
          'Language'      => 'Language1 (10)',
          'Location'      => 'Location1 (10)',
          'Publisher'     => 'Publisher1 (10)',
          'Format'        => 'plain () (10)'
        }.each_value do |value|
          within('#facets') do
            # open facet
            expect(page).to have_content(value, wait: Capybara.default_max_wait_time * 2)
          end
        end
        Capybara.ignore_hidden_elements = @original_value

        # When I search by partial title it does not display any results
        search_my_files_by_term('title')
        expect(page).to have_content 'You searched for: title'
        page_should_not_list_any_files

        # When I search by title using exact words it displays the correct results
        search_my_files_by_term(work1.title.first)
        expect(page).to have_content "You searched for: #{work1.title.first}"
        page_should_only_list work1

        # To Do resource type does not seem to be searchable
        ## When I search by Resource Type it displays the correct results
        # search_my_files_by_term( work1.resource_type )
        # expect(page).to have_content "You searched for: #{work1.resource_type}"
        # page_should_only_list work1

        # When I search by Keywords it displays the correct results
        search_my_files_by_term(work1.keyword.first)
        expect(page).to have_content "You searched for: #{work1.keyword.first}"
        page_should_only_list work1

        # allows me to remove constraints
        find('span.glyphicon-remove').click
        expect(page).to have_no_content 'You searched for:'

        # When I search by Creator it displays the correct results
        search_my_files_by_term(work1_creator_name)
        expect(page).to have_content "You searched for: #{work1_creator_name}"
        page_should_only_list work1
      end
    end

    describe 'Sorting:' do
      specify 'Items are sorted correctly' do
        select('date uploaded ▼', from: 'sort')
        click_button('Refresh')
        expect(page).to have_content(work1.title.first)
        select('date uploaded ▲', from: 'sort')
        click_button('Refresh')
        expect(page).not_to have_content(work1.title.first)
      end
    end

    context 'with collection of other users' do
      let!(:other_collection) do
        create(:collection, id: 'dashboard-works-other_collection', title: ['jill collection'], depositor: jill.login)
      end

      it "does not show other user's collection" do
        first('input.batch_document_selector').click
        click_button 'Add to Collection'
        expect(page).to have_css('#collection-list-container')
        expect(page).not_to have_content(other_collection.title)
      end
    end
  end

  context 'Many Works' do
    before do
      create_works(current_user, 30)
      go_to_dashboard_works
    end

    after do
      30.times do |t|
        conn.delete_by_id "199#{t}"
      end
      conn.commit
    end

    it 'Changing the number per page on other pages of My Works redirects to page 1' do
      # Changes to make sure we do not end up off the last page when changing page size
      #
      expect(GenericWork.count).to eq(32)
      within('.pagination') do
        click_link('3')
      end
      within('.per_page') do
        expect(page).not_to have_selector("input[name='page'][value='5']", visible: false)
      end
      expect(page).to have_css('.batch_document_selector_all')
      select('100', from: 'per_page')
      select('100', from: 'per_page')
      find_button('Refresh').click
      expect(page).to have_no_css('.pagination')
      expect(page).to have_no_css('.pager')

      # TODO what is the maximum batch?  Do we still need to remove the select all?
      # expect(page).not_to have_css('.batch_document_selector_all')

      # check to make sure clicking a check box toggles
      # collection addition/work edit & deletion or Sort By
      #
      first('input.batch_document_selector').click
      within('.batch-info') do
        expect(page).to have_content 'Add to Collection'
        expect(page).not_to have_content 'Sort By'
      end
      first('input.batch_document_selector').click
      within('.batch-info') do
        expect(page).to have_content 'Sort By'
        expect(page).not_to have_content 'Add to Collection'
      end
    end
  end

  def search_my_files_by_term(term)
    within('#search-form-header') do
      expect(page).to have_content('My Works')
      fill_in('search-field-header', with: term)
      click_button('Go')
    end
  end

  let(:title_field) { Solrizer.solr_name('title', :stored_searchable, type: :string) }
  let(:resp) { ActiveFedora::SolrService.instance.conn.get 'select', params: { fl: ['id', title_field] } }

  def page_should_only_list(work1)
    expect(page).to have_selector('li.active', text: 'My Works')
    expect(page).to have_content work1.title.first
    resp['response']['docs'].each do |gf|
      unless gf[title_field].nil?
        title = gf[title_field].first
        expect(page).not_to have_content title unless title == work1.title.first
      end
    end
  end

  def page_should_not_list_any_files
    resp['response']['docs'].each do |gf|
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

  def create_works(user, number_of_works)
    number_of_works.times do |t|
      work = build(:public_work, id: "199#{t}",
                                 title: ["Sample Work #{t}"],
                                 date_uploaded: (Time.now - (t + 1).hours),
                                 depositor: user.login, resource_type: ['Video'],
                                 keyword: ['Keyword1'],
                                 subject: ['Subject1'], language: ['Language1'],
                                 based_near: ['Location1'], publisher: ['Publisher1'],
                                 representative: build(:file_set, :with_file_format))

      # Stub ordered creators because we haven't persisted any data
      allow(work).to receive(:creators).and_return([Alias.new(display_name: 'Creator1 Jones')])

      conn.add(work.to_solr)
    end
    conn.commit
  end
end
