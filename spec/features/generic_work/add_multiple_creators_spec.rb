# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a Generic Work with multiple Creators', :clean, js: true do
  context 'a logged in user' do
    let(:user) { create(:user, display_name: 'First User') }

    before do
      login_as user
      p = Agent.create(given_name: 'Testing', sur_name: 'Person', email: 'person@email.com', psu_id: 'tp01')
      create(:alias, display_name: 'Testing Person', agent: p)
    end

    scenario do
      visit '/concern/generic_works/new'
      # Adding a blank creator field
      click_button 'add-creator'
      click_button 'add-creator'
      expect(page).to have_selector('.creator_inputs', count: 3)

      # Remove a creator field
      execute_script("$('.remove-creator')[0].click()")
      expect(page).to have_selector('.creator_inputs', count: 2)

      # Autocomplete returns a result from Agents
      page.execute_script "$('#find_creator').unbind('blur')"
      fill_in('Find Creator', with: 'Testing')
      expect(page).to have_selector('.tt-suggestion')

      # Add creator field from autocomplete results
      page.execute_script('$(".tt-suggestion").click()')
      expect(page).to have_selector('.creator_inputs', count: 3)
      expect(page).to have_field('generic_work[creators][2][given_name]', readonly: true)
      expect(page).to have_field('generic_work[creators][2][sur_name]', readonly: true)
      expect(page).to have_field('generic_work[creators][2][email]', readonly: true)
      expect(page).to have_field('generic_work[creators][2][psu_id]', readonly: true)

      # Remove the autocompleted creator field
      execute_script("$('.remove-creator')[2].click()")
      expect(page).to have_selector('.creator_inputs', count: 2)
    end
  end
end
