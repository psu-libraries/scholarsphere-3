# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionSearchBuilder do
  let(:context) { double }
  let(:builder) { described_class.new(context).with(blacklight_params) }
  let(:solr_params) { Blacklight::Solr::Request.new }
  let(:blacklight_params) { { q: user_query, search_field: 'all_fields' } }
  let(:user_query) { 'find me' }

  describe '#show_works_or_works_that_contain_files' do
    subject { builder.rows }

    it { is_expected.to eq(1000) }
    it 'counts collections' do
      allow(ScholarSphere::Application.config).to receive(:max_collection_query_rows).and_return(5)
      expect(builder.rows).to eq(5)
    end
  end
end
