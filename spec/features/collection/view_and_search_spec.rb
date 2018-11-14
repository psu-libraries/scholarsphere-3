
# frozen_string_literal: true

require 'feature_spec_helper'

include Selectors::Dashboard

describe Collection, type: :feature, js: true do
  let(:creator) { create(:alias, :with_agent) }

  let!(:collection) do
    create(:public_collection, :with_complete_metadata,
      creators: [creator],
      depositor: current_user.login,
      identifier: ['doi:blah-blah'],
      members: [file1, file2])
  end

  let(:current_user) { create(:user) }

  let(:file1) do
    create(:public_file, :with_one_file_and_size, title: ['world.png'], depositor: current_user.login)
  end

  let(:file2) do
    create(:private_file, :with_one_file_and_size, title: ['little_file.txt'], depositor: current_user.login)
  end

  context 'with a logged in user' do
    before do
      login_as(current_user)
      visit("/collections/#{collection.id}")
    end

    it 'shows the collection and searches within it' do
      expect(page).to have_content collection.title.first
      expect(page).to have_content collection.description.first
      expect(page).to have_content collection.creator.first.display_name
      expect(page).to have_selector("a[href='/catalog?f%5Bcreator_name_sim%5D%5B%5D=Given+Name+Sur+Name']")
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

  context 'with a public user' do
    it 'displays the collection and only public files' do
      visit "/collections/#{collection.id}"
      expect(page).to have_content collection.title.first
      expect(page).to have_content file1.title.first
      expect(page).not_to have_content file2.title.first
    end
  end
end
