# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Featured works on the home page', type: :feature, js: true do
  let!(:user)         { create(:user) }
  let!(:jill_user)    { create(:jill) }
  let!(:file1)        { create(:featured_file, depositor: user.login, title: ['file title'], keyword: ["'55 Chet Atkins"]) }
  let!(:file2)        { create(:featured_file, :with_required_metadata, depositor: user.login) }
  let!(:private_file) { create(:private_file, depositor: jill_user.login, title: ['private_document']) }

  let(:admin_user) { create(:administrator) }

  context 'as a normal user' do
    before do
      login_as user
      visit('/')
    end

    it 'appears as a featured work with translated facets', js: true do
      expect(page).to have_content 'Featured Works'
      within('#featured_container') do
        expect(page).to have_content(file1.title[0])
        click_link(file1.keyword.first)
      end
      expect(page).to have_content(file1.title[0])
    end

    it 'only public documents appear as recently uploaded files' do
      click_link 'Recent Additions'
      within('#recently_uploaded') do
        expect(page).to have_content(file1.title[0])
        expect(page).to have_no_content(private_file.title[0])
      end
    end
  end

  context 'as an administrator' do
    before do
      login_as admin_user
      visit('/')
    end

    it 'allows the user to remove it as a featured work' do
      document = find('li.dd-item:nth-of-type(1)')
      expect(document['data-id']).to eq(file1.id)

      within('li.dd-item:nth-of-type(1)') do
        expect(page).to have_css '.glyphicon-remove'
        find('.glyphicon-remove').click
        expect(page).to have_no_content(file1.title[0])
      end
    end

    it 'allows the user to save the order' do
      within('#featured_container') do
        click_on 'Save order'
      end
      expect(page).to have_content(file1.title[0])
      expect(page).to have_content(file2.title[0])
    end

    it 'removes a featured work if it becomes private' do
      within('#featured_container') do
        expect(page).to have_content(file2.title[0])
      end

      file2.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      file2.save
      visit('/')

      within('#featured_container') do
        expect(page).not_to have_content(file2.title[0])
      end
    end
  end
end
