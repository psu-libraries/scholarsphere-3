# frozen_string_literal: true

require 'feature_spec_helper'

describe FileSet, type: :feature, unless: travis?, normal_characterize: true do
  context "when searching the file set's extraced text" do
    let!(:current_user) { create(:user) }
    let!(:work) { create(:public_work_with_pdf, title: ['Full-text work'], depositor: current_user.login) }

    before do
      GenericWork.all.map(&:update_index)
      FileSet.all.map(&:update_index)
      sign_in(current_user)
    end

    it "returns the file set's containing work" do
      visit(root_path)
      within('#search-form-header') do
        fill_in('search-field-header', with: 'brown fox')
        click_button('Go')
      end
      within('div#content') do
        expect(page).to have_selector('h3', text: 'Full-text work')
      end
    end
  end
end
