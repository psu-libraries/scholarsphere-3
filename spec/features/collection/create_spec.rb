# frozen_string_literal: true

require 'feature_spec_helper'

include Selectors::Dashboard

describe Collection, type: :feature, js: true do
  let(:current_user) { create(:user, display_name: 'Jill User') }
  let(:title)        { 'Test Collection Title' }
  let(:subtitle)     { 'Machu Picchu' }

  before { login_as(current_user) }

  describe 'creating a new collection from the dashboard' do
    it 'displays the new collection page' do
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
    end
  end

  describe 'creating new collections' do
    before do
      visit(new_collection_path)
      fill_in 'Title', with: title
      fill_in 'Subtitle', with: subtitle
      fill_in 'Description', with: 'description'
      fill_in 'Keyword', with: 'keyword'
    end

    context 'without any files' do
      let(:doi)      { 'doi:abc123' }
      let(:client)   { instance_double(Ezid::Client) }
      let(:response) { instance_double(Ezid::MintIdentifierResponse, id: doi) }

      before do
        allow(Ezid::Client).to receive(:new).and_return(client)
        allow(client).to receive(:mint_identifier).and_return(response)
      end

      it 'creates an empty collection' do
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
        expect(page).to have_content('https://doi.org')

        # The link to the creator search should look like this
        # with the correct solr key 'creator_name_sim':
        # catalog?f[creator_name_sim][]=Jill+User
        expect(find_link('Jill User')[:href]).to match /catalog\?f%5Bcreator_name_sim%5D%5B%5D=Jill\+User/
      end
    end

    context 'when adding existing works' do
      let!(:file1) { create(:file, title: ['First file'], depositor: current_user.login) }
      let!(:file2) { create(:file, title: ['Second file'], depositor: current_user.login) }

      it 'adds existing works after the collection is created' do
        click_button 'Create Collection and Add Existing Works'
        expect(page).to have_content('Collection was successfully created.')
        check 'check_all'
        click_button "Add to #{title}"
        expect(page).to have_content(title)
        within('dl.metadata-collections') do
          expect(page).to have_content('Total Items')
          expect(page).to have_content('2')
        end
        within('table.table-striped') do
          expect(page).to have_content('First file')
          expect(page).to have_content('Second file')
        end
      end
    end

    context 'when adding new works' do
      it 'creates new works after the collection is created' do
        click_button 'Create Collection and Upload Works'
        expect(page).to have_content('Collection was successfully created.')
        expect(page).to have_content('Add Multiple New Works')
        within('ul.nav-tabs') { click_link('Collections') }
        expect(page).to have_select('batch_upload_item_collection_ids', selected: title)
      end
    end
  end

  describe 'selecting files from the dashboard' do
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
