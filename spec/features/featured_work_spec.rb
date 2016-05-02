# frozen_string_literal: true
require 'feature_spec_helper'

describe "Featured works on the home page", type: :feature do
  let!(:user)         { create(:user) }
  let!(:jill_user)    { create(:jill) }
  let!(:file1)        { create(:featured_file, depositor: user.login, title: ['file title']) }
  let!(:file2)        { create(:featured_file, depositor: user.login, title: ['another_title_bites_the_dust']) }
  let!(:private_file) { create(:private_file, depositor: jill_user.login, title: ['private_document']) }

  let(:admin_user) { create(:administrator) }

  context "as a normal user" do
    before do
      sign_in_with_js(user)
      visit("/")
    end

    it "appears as a featured work", js: true do
      expect(page).to have_content "Featured Works"
      within("#featured_container") do
        expect(page).to have_content(file1.title[0])
      end
    end

    it "only public documents appear as recently uploaded files" do
      click_link "Recent Additions"
      within("#recently_uploaded") do
        expect(page).to have_content(file1.title[0])
        expect(page).to have_no_content(private_file.title[0])
      end
    end
  end

  context "as an administrator" do
    before do
      sign_in_with_js(admin_user)
      visit("/")
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

    it 'removes a featured work if it becomes private' do
      pending("PR: projecthydra/sufia#1953")
      within('#featured_container') do
        expect(page).to have_content(file2.title[0])
      end

      click_on file2.title[0]
      click_on 'Edit'
      choose 'generic_work_visibility_restricted'
      click_on 'Save'
      visit '/'

      within('#featured_container') do
        expect(page).to have_no_content(file2.title[0])
      end
    end
  end
end
