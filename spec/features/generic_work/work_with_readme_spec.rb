# frozen_string_literal: true

require 'feature_spec_helper'

describe GenericWork do
  let!(:current_user) { create(:user) }
  let!(:work) { create(:public_work_with_readme, title: ['Work with README'], depositor: current_user.login) }

  before do
    described_class.all.map(&:update_index)
    FileSet.all.map(&:update_index)
    sign_in(current_user)
  end

  it 'displays the contents of the readme' do
    visit(polymorphic_path(work))
    expect(page).to have_content('This is a readme for testing.')
  end

  context 'work readme with prompt' do
    let!(:work) { create(:public_work, title: ['Work with out README'], depositor: current_user.login, resource_type: ['Audio']) }

    it 'displays the contents of the prompt' do
      visit(polymorphic_path(work))
      expect(page).to have_content('How about adding a README file?')
    end
  end

  context 'work without readme with prompt' do
    let!(:work) { create(:public_work, title: ['Work with out README'], depositor: current_user.login, resource_type: ['Book']) }

    it 'displays the contents of the prompt' do
      visit(polymorphic_path(work))
      expect(page).not_to have_content('How about adding a README file?')
    end
  end
end
