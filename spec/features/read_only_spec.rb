# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Read only system', type: :feature do
  let(:current_user) { create(:user) }
  let(:file) { create(:file, depositor: current_user.login) }
  let(:work) { create(:work, depositor: current_user.login) }
  let(:collection) { create(:collection, depositor: current_user.login) }

  before do
    sign_in(current_user)
    allow(ScholarSphere::Application.config).to receive(:read_only).and_return(true)
  end

  specify 'I cannot access the upload page' do
    visit Rails.application.routes.url_helpers.new_curation_concerns_generic_work_path
    expect(page).to have_content 'Read Only'
    expect(page).not_to have_content 'Upload'
    expect(page).to have_content 'Read Only'
    visit Rails.application.routes.url_helpers.new_collection_path
    expect(page).to have_content 'Read Only'
    visit Rails.application.routes.url_helpers.edit_curation_concerns_generic_work_path(work.id)
    expect(page).to have_content 'Read Only'
    visit Rails.application.routes.url_helpers.edit_collection_path(collection.id)
    expect(page).to have_content 'Read Only'
  end
end
