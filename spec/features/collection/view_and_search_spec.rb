
# frozen_string_literal: true

require 'feature_spec_helper'

include Selectors::Dashboard

describe Collection, type: :feature, js: true do
  let(:creator) { create(:alias, :with_agent) }

  let!(:collection) do
    create(:public_collection, :with_complete_metadata,
      creators: [creator],
      depositor: current_user.login,
      identifier: ['doi:blah-blah'],
      members: [file1, file2])
  end

  let(:current_user) { create(:user) }

  let(:file1) do
    create(:public_file, :with_one_file_and_size, title: ['world.png'], depositor: current_user.login)
  end

  let(:file2) do
    create(:private_file, :with_one_file_and_size, title: ['little_file.txt'], depositor: current_user.login)
  end

  context 'with a public user' do
    it 'displays the collection and only public files' do
      visit "/collections/#{collection.id}"
      expect(page).to have_content collection.title.first
      expect(page).to have_content file1.title.first
      expect(page).not_to have_content file2.title.first
    end
  end
end
