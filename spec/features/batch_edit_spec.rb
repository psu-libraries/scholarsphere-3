# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Batch management of works', type: :feature do
  let(:current_user) { create(:user) }

  let(:first_creator) do
    create(:alias, display_name: 'First Creator', agent: Agent.new(given_name: 'First', sur_name: 'Creator'))
  end

  let(:second_creator) do
    create(:alias, display_name: 'Second Creator', agent: Agent.new(given_name: 'Second', sur_name: 'Creator'))
  end

  let!(:work1) do
    create(:public_work, :with_complete_metadata,
           creators: [first_creator, second_creator],
           depositor: current_user.login)
  end

  let!(:work2) do
    create(:public_work, :with_complete_metadata,
           creators: [first_creator, second_creator],
           depositor: current_user.login)
  end

  before do
    sign_in_with_named_js(:batch_edit, current_user, disable_animations: true)
    visit '/dashboard/works'
  end

  context 'when editing and viewing multiple works' do
    before do
      check('check_all')
      click_on('batch-edit')
    end

    it 'edits a field and displays the changes', js: true do
      expect(page).to have_content 'Changes will be applied to the following'

      # check the form has the correct values
      @original_value = Capybara.ignore_hidden_elements
      Capybara.ignore_hidden_elements = false
      within('textarea#batch_edit_item_description') do
        expect(page).to have_content('descriptiondescription')
      end
      expect(page).to have_css "input#batch_edit_item_contributor[value*='contributorcontributor']"
      expect(page).to have_css "input#batch_edit_item_keyword[value*='tagtag']"
      expect(page).to have_css "input#batch_edit_item_based_near[value*='based_nearbased_near']"
      expect(page).to have_css "input#batch_edit_item_language[value*='languagelanguage']"
      expect(find_field(id: 'batch_edit_item[creators][0][given_name]').value).to eq('First')
      expect(find_field(id: 'batch_edit_item[creators][0][sur_name]').value).to eq('Creator')
      expect(find_field(id: 'batch_edit_item[creators][0][display_name]').value).to eq('First Creator')
      expect(find_field(id: 'batch_edit_item[creators][1][given_name]').value).to eq('Second')
      expect(find_field(id: 'batch_edit_item[creators][1][sur_name]').value).to eq('Creator')
      expect(find_field(id: 'batch_edit_item[creators][1][display_name]').value).to eq('Second Creator')
      expect(page).to have_css "input#batch_edit_item_publisher[value*='publisherpublisher']"
      expect(page).to have_css "input#batch_edit_item_subject[value*='subjectsubject']"
      expect(page).to have_css "input#batch_edit_item_related_url[value*='http://example.org/TheRelatedURLLink/']"
      expect(page).to have_no_checked_field('Private')
      expect(page).to have_content(I18n.t('scholarsphere.batch_edit.permissions_warning'))
      Capybara.ignore_hidden_elements = @original_value

      # Update standard fields
      batch_edit_fields.each do |field|
        fill_in_batch_edit_field(field, with: "Updated batch #{field}")
      end

      # Update creators
      click_link 'expand_link_creator'
      first('.remove-creator').click
      fill_in 'batch_edit_item[creators][1][display_name]', with: 'Dr. Creator C. Creator, MD'
      click_button('Add another Creator')
      fill_in 'batch_edit_item[creators][2][display_name]', with: 'Another Creator'
      fill_in 'batch_edit_item[creators][2][given_name]', with: 'Another'
      fill_in 'batch_edit_item[creators][2][sur_name]', with: 'Creator'
      click_button('creator_save')
      within '#form_creator' do
        sleep 0.1 until page.text.include?('Changes Saved')
        expect(page).to have_content 'Changes Saved', wait: Capybara.default_max_wait_time * 4
      end

      # Update rights for all works to a single value
      click_link 'expand_link_rights'
      select 'GNU General Public License', from: 'batch_edit_item_rights'
      click_button('rights_save')
      within '#form_rights' do
        sleep 0.1 until page.text.include?('Changes Saved')
        expect(page).to have_content 'Changes Saved', wait: Capybara.default_max_wait_time * 4
      end

      # Verify changes
      work1.reload
      work2.reload
      batch_edit_fields.each do |field|
        expect(work1.send(field)).to contain_exactly("Updated batch #{field}")
        expect(work2.send(field)).to contain_exactly("Updated batch #{field}")
      end
      expect(work1.creators.map(&:display_name)).to contain_exactly('Dr. Creator C. Creator, MD', 'Another Creator')
      expect(work1.creators.map(&:agent).map(&:sur_name)).to contain_exactly('Creator', 'Creator')
      expect(work1.creators.map(&:agent).map(&:given_name)).to contain_exactly('Another', 'Second')
      expect(work2.creators.map(&:display_name)).to contain_exactly('Dr. Creator C. Creator, MD', 'Another Creator')
      expect(work2.creators.map(&:agent).map(&:sur_name)).to contain_exactly('Creator', 'Creator')
      expect(work2.creators.map(&:agent).map(&:given_name)).to contain_exactly('Another', 'Second')
    end
  end

  context 'when selecting multiple works for deletion', js: true do
    before do
      check 'check_all'
      accept_confirm { click_button('Delete Selected') }
    end

    it 'deletes all the works' do
      expect(page).to have_content('Batch delete complete')
      expect(GenericWork.count).to be_zero
    end
  end
end
