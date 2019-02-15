# frozen_string_literal: true

require 'feature_spec_helper'

describe Collection, type: :feature, js: true do
  include Selectors::Dashboard

  let(:current_user) { create(:user, display_name: 'Jill User') }
  let(:title)        { 'Test Collection Title' }
  let(:subtitle)     { 'Machu Picchu' }
  let(:description)  { 'Stuff that I am describing' }
  let(:updated_title)        { 'Updated Title' }
  let(:updated_subtitle)     { 'Updated Vimana2' }
  let(:updated_description)  { 'Updated description text.' }

  before { login_as(current_user) }

  context 'without any files' do
    let(:doi)      { 'doi:abc123' }
    let(:client)   { instance_double(Ezid::Client) }
    let(:response) { instance_double(Ezid::MintIdentifierResponse, id: doi) }

    before do
      allow(Ezid::Client).to receive(:new).and_return(client)
      allow(client).to receive(:mint_identifier).and_return(response)
    end

    it 'creates an empty collection' do
      go_to_dashboard
      db_create_empty_collection_button.click
      expect(page).to have_content('Create New Collection')
      within('div#descriptions_display') do
        expect(page).to have_selector('label', class: 'required', text: 'Title')
        expect(page).to have_selector('label', text: 'Subtitle')
        expect(page).to have_selector('label', class: 'required', text: 'Description')
        expect(page).to have_selector('label', class: 'required', text: 'Keyword')
      end
      within('div.collection_form_visibility') do
        expect(find('input#visibility_open')).to be_checked
      end
      expect(page).to have_content('Create a DOI for this collection')

      fill_in 'Title', with: title
      fill_in 'Subtitle', with: subtitle
      fill_in 'Description', with: description
      fill_in 'Keyword', with: 'keyword'
      within('div#share') do
        expect(page).to have_content('Add Group')
        select 'umg/up.dlt.scholarsphere-users', from: 'new_group_name_skel'
        select 'Edit', from: 'new_group_permission_skel'
        click_button 'Add Group'
        expect(page).to have_selector("input[value='umg/up.dlt.scholarsphere-users']", visible: false)
      end
      check 'collection_create_doi'
      click_button 'Create Empty Collection'
      expect(page).to have_content('Collection was successfully created.')
      within('header') do
        within('h1') do
          expect(page).to have_content(title)
        end
        within('p') do
          expect(page).to have_content(subtitle)
        end
      end
      expect(page).to have_selector("a[href='https://doi.org/abc123']")

      # The link to the creator search should look like this
      # with the correct solr key 'creator_name_sim':
      # catalog?f[creator_name_sim][]=Jill+User
      expect(find_link('Jill User')[:href]).to match /catalog\?f%5Bcreator_name_sim%5D%5B%5D=Jill\+User/

      # Test Edit
      click_link 'Edit'
      expect(page).to have_field 'collection_title', with: title
      expect(page).to have_field 'collection_subtitle', with: subtitle
      expect(page).to have_field 'collection_description', with: description

      within('div#share') do
        select 'umg/up.dlt.scholarsphere-users', from: 'new_group_name_skel'
        select 'Edit', from: 'new_group_permission_skel'
        page.find('#add_new_group_skel').click
        expect(page).to have_selector("input[value='umg/up.dlt.scholarsphere-users']", visible: false)
      end

      click_link 'Additional Fields'
      within('div.collection_date_created') do
        expect(page).to have_content('Published Date')
        fill_in 'Published Date', with: 'Date Published'
      end
      expect(page).to have_checked_field('Public')
      expect(page).to have_no_checked_field('Private')
      fill_in 'Title', with: updated_title
      fill_in 'Subtitle', with: updated_subtitle
      fill_in 'Description', with: updated_description
      expect(find('.creator-first-name')['readonly']).to eq('true')
      expect(find('.creator-last-name')['readonly']).to eq('true')
      fill_in 'collection[creators][0][display_name]', with: 'Mdme. Dorje Trollo'
      click_button 'Update Collection'
      expect(page).not_to have_content title
      expect(page).not_to have_content description
      expect(page).to have_content updated_title
      expect(page).to have_content updated_subtitle
      expect(page).to have_content updated_description
      expect(page).to have_content 'Mdme. Dorje Trollo'
      within('dl.metadata-collections') do
        expect(page).to have_content('Published Date')
      end

      expect(Collection.last.edit_groups).to contain_exactly('umg/up.dlt.scholarsphere-users')

      # Test Delete
      accept_confirm { click_link 'Delete' }
      expect(page).to have_content 'Collection was successfully deleted'
      within('#my_nav') do
        expect(page).to have_content('My Collections')
      end
      within('#documents') do
        expect(page).not_to have_content title
      end
    end
  end

  context 'with existing works' do
    let!(:file1) { create(:file, title: ['First file'], depositor: current_user.login) }
    let!(:file2) { create(:file, title: ['Second file'], depositor: current_user.login) }

    it 'adds existing works after the collection is created' do
      visit(new_collection_path)
      fill_in 'Title', with: title
      fill_in 'Subtitle', with: subtitle
      fill_in 'Description', with: description
      fill_in 'Keyword', with: 'keyword'
      fill_in 'collection[creators][0][display_name]', with: 'Mdme. Dorje Trollo'
      click_button 'Create Collection and Add Existing Works'
      expect(page).to have_content('Collection was successfully created.')
      check 'check_all'
      click_button "Add to #{title}"

      # Test the view
      expect(page).to have_content(title)
      within('dl.metadata-collections') do
        expect(page).to have_content("Total Items\n2")
        expect(page).to have_content("Size\n0 Bytes")
      end
      within('table.table-striped') do
        expect(page).to have_content('First file')
        expect(page).to have_content('Second file')
      end
      expect(page).to have_selector("a[href='/catalog?f%5Bcreator_name_sim%5D%5B%5D=Jill+User']")

      within('div.actions-controls-collections') do
        expect(page).to have_content('Download Collection as Zip')
      end

      # Test the search within the collection
      fill_in 'collection_search', with: file1.title.first
      click_button 'collection_submit'
      expect(page).to have_content 'Search Results within this Collection'
      expect(page).to have_content title
      expect(page).to have_content description

      # Should have search results / contents listing
      expect(page).to have_content file1.title.first
      expect(page).not_to have_content file2.title.first

      # Should not have Collection Descriptive metadata table
      expect(page).not_to have_selector 'dl.metadata-collections'
    end
  end

  context 'with new works' do
    it 'creates new works after the collection is created' do
      visit(new_collection_path)
      fill_in 'Title', with: title
      fill_in 'Subtitle', with: subtitle
      fill_in 'Description', with: 'description'
      fill_in 'Keyword', with: 'keyword'
      click_button 'Create Collection and Upload Works'
      expect(page).to have_content('Collection was successfully created.')
      expect(page).to have_content('Add Multiple New Works')
      within('ul.nav-tabs') { click_link('Collections') }
      expect(page).to have_select('batch_upload_item_collection_ids', selected: title)
    end
  end

  context 'when selecting files from the dashboard' do
    let!(:file1) { create(:file, title: ['First file'], depositor: current_user.login) }
    let!(:file2) { create(:file, title: ['Second file'], depositor: current_user.login) }

    it 'creates a new collection using the selected files' do
      go_to_dashboard_works
      check 'check_all'
      click_button 'Add to Collection'
      db_create_populated_collection_button.click
      fill_in 'Title', with: title
      fill_in 'Subtitle', with: subtitle
      fill_in 'Description', with: 'description'
      fill_in 'Keyword', with: 'keyword'
      within('div.primary-actions') do
        expect(page).not_to have_button('Create Empty Collection')
        expect(page).not_to have_button('Create Collection and Upload Works')
        expect(page).not_to have_button('Create Collection and Add Existing Works')
      end
      within('table.table-striped') do
        expect(page).to have_content('First file')
        expect(page).to have_content('Second file')
      end
      click_button('Create New Collection')
      expect(page).to have_content 'Collection was successfully created.'
      expect(page).to have_content file1.title.first
      expect(page).to have_content file2.title.first
    end
  end
end
