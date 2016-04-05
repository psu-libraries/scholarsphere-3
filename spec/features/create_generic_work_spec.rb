# frozen_string_literal: true
# Generated via
#  `rails generate curation_concerns:work GenericWork`
require 'spec_helper'
include Warden::Test::Helpers

feature 'Create a GenericWork' do
  context 'a logged in user' do
    let(:user_attributes) do
      { login: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      login_as user
    end

    scenario do
      visit new_curation_concerns_generic_work_path
      fill_in 'Title', with: 'Test GenericWork'
      click_button 'Create GenericWork'
      expect(page).to have_content 'Test GenericWork'
    end
  end
end
