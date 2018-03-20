
# frozen_string_literal: true

require 'feature_spec_helper'

include Selectors::Dashboard

describe Collection, type: :feature do
  let(:creator) { create(:alias, :with_agent) }

  let!(:collection)  { create(:public_collection, :with_complete_metadata,
                              creators: [creator],
                              depositor: current_user.login,
                              identifier: ['doi:blah-blah'],
                              members: [file1, file2]) }

  let(:current_user) { create(:user) }

  let(:file1)        { create(:public_file, :with_one_file_and_size,
                              title: ['world.png'],
                              depositor: current_user.login) }

  let(:file2)        { create(:private_file, :with_one_file_and_size,
                              title: ['little_file.txt'],
                              depositor: current_user.login) }

  context 'with a logged in user' do
    before do
      sign_in_with_js(current_user)
      visit("/collections/#{collection.id}")
    end

    describe 'viewing a collection and its files' do
      specify do
        expect(page).to have_content collection.title.first
        expect(page).to have_content collection.description.first
        expect(page).to have_content collection.creator.first.display_name
        expect(page).to have_selector("a[href='https://doi.org/blah-blah']")
        expect(page).to have_content file1.title.first
        expect(page).to have_content file2.title.first
        expect(page).to have_content 'Total Items 2'
        expect(page).to have_content 'Size 2 Bytes'

        within('div.actions-controls-collections') do
          expect(page).to have_content('Download Collection as Zip')
        end

        within('dl.metadata-collections') do
          expect(page).to have_content('Published Date')
        end
        go_to_dashboard_works

        # TODO: Re-add this test once ticket https://github.com/psu-stewardship/scholarsphere/issues/294
        # has been completed. Or totally remove the commented test if the ticket is closed.
        # expect(page).to have_content "Is part of: #{collection.title}"

        expect(page).to have_link('My Works')
        expect(page).to have_link('My Collections')
      end
    end

    describe 'searching within a collection' do
      specify do
        fill_in 'collection_search', with: file1.title.first
        click_button 'collection_submit'
        expect(page).to have_content collection.title.first
        expect(page).to have_content collection.description.first

        # Should have search results / contents listing
        expect(page).to have_content file1.title.first
        expect(page).not_to have_content file2.title.first

        # Should not have Collection Descriptive metadata table
        expect(page).not_to have_content collection.creator.first.display_name
      end
    end

    describe 'adding existing works' do
      specify do
        click_link('Add existing works')
        check 'check_all'
        expect(page).to have_button("Add to #{collection.title.first}")
      end
    end

    describe 'adding new works' do
      specify do
        click_link('Add new works')
        expect(page).to have_content('Add Multiple New Works')
        within('ul.nav-tabs') { click_link('Collections') }
        expect(page).to have_select('batch_upload_item_collection_ids', selected: collection.title.first)
      end
    end
  end

  context 'with a public user' do
    it 'displays the collection and only public files' do
      visit "/collections/#{collection.id}"
      expect(page.status_code).to eql(200)
      expect(page).to have_content collection.title.first
      expect(page).to have_content file1.title.first
      expect(page).not_to have_content file2.title.first
    end
  end
end
