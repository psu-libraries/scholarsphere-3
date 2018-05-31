# frozen_string_literal: true

require 'rails_helper'

describe 'collections/_show_actions.html.erb' do
  include Devise::Test::ControllerHelpers

  let(:collection) { build(:collection, id: '1') }
  let(:presenter) { CollectionPresenter.new(SolrDocument.new(collection.to_solr), Ability.new(nil)) }

  before do
    render 'collections/show_actions.html.erb', presenter: presenter, member_docs: member_docs
  end

  context 'when there are no members of the collection available to display' do
    let(:member_docs) { [] }

    it 'does not show the zip download link' do
      expect(rendered).not_to include('Download Collection as Zip')
    end
  end

  context 'with collection members present' do
    let(:member_docs) { ['doc'] }

    it 'shows the zip download link' do
      expect(rendered).to include('Download Collection as Zip')
    end
  end
end
