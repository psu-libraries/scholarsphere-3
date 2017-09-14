# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a Generic Work with multiple Creators', :clean, js: true do
  context 'a logged in user' do
    let(:user) { create(:user, display_name: 'First User') }

    before do
      login_as user
      p = Person.new(given_name: 'Testing', sur_name: 'Person')
      p.save!
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

      # Autocomplete returns a result from Persons
      page.execute_script "$('#find_creator').unbind('blur')"
      fill_in('Find Creator', with: 'Testing')
      expect(page).to have_selector('.tt-suggestion')

      # Add creator field from autocomplete results
      page.execute_script('$(".tt-suggestion").click()')
      expect(page).to have_selector('.creator_inputs', count: 3)
    end
  end
end
