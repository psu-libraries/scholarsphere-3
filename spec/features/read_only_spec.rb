# frozen_string_literal: true
require 'feature_spec_helper'

describe 'Read only system', type: :feature do
  let(:current_user) { create(:user) }
  let(:file) { create(:file, depositor: current_user.login) }
  let(:collection) { create(:collection, depositor: current_user.login) }

  before do
    sign_in(current_user)
    allow(ScholarSphere::Application.config).to receive(:read_only).and_return(true)
  end

  specify 'I cannot access the upload page' do
    visit Sufia::Engine.routes.url_helpers.new_generic_file_path
    expect(page).to have_content 'Read Only'
    expect(page).not_to have_content 'Upload'
    visit Hydra::Collections::Engine.routes.url_helpers.new_collection_path
    expect(page).to have_content 'Read Only'
    expect(page).not_to have_content 'Create Collection'
    visit Sufia::Engine.routes.url_helpers.edit_generic_file_path(file.id)
    expect(page).to have_content 'Read Only'
    expect(page).not_to have_content 'Edit'
    visit Hydra::Collections::Engine.routes.url_helpers.edit_collection_path(collection.id)
    expect(page).to have_content 'Read Only'
    expect(page).not_to have_content 'Edit Collection'
  end
end
