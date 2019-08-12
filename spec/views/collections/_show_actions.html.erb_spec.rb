# frozen_string_literal: true

require 'rails_helper'

describe 'collections/_show_actions.html.erb' do
  include Devise::Test::ControllerHelpers

  let(:collection) { build(:collection, id: '1') }
  let(:presenter) { CollectionPresenter.new(SolrDocument.new(collection.to_solr), Ability.new(nil)) }

  context 'when a zip file is not available' do
    before do
      allow(presenter).to receive(:zip_available?).and_return(false)
      render 'collections/show_actions.html.erb', presenter: presenter
    end

    it 'does not show the zip download link' do
      expect(rendered).not_to include('Download Collection as Zip')
    end
  end

  context 'when a zip file is available' do
    before do
      allow(presenter).to receive(:zip_available?).and_return(true)
      render 'collections/show_actions.html.erb', presenter: presenter
    end

    it 'shows the zip download link' do
      expect(rendered).to include('Download Collection as Zip')
    end
  end
end
