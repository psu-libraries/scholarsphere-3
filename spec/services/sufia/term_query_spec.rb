# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sufia::Statistics::TermQuery do
  before(:all) do
    class ByMyTerm < Sufia::Statistics::TermQuery
      private

        def index_key
          'foo_field_sim'
        end
    end
  end

  after(:all) do
    ActiveSupport::Dependencies.remove_constant('ByMyTerm')
  end

  let(:term) { ByMyTerm.new }

  context 'when Solr is configured to respond' do
    it 'returns an accurate response' do
      expect(Rails.logger).not_to receive(:error)
      expect(term.query).to eq([])
    end
  end

  context 'when Solr is mis-configured' do
    let(:connection) { ActiveFedora::SolrService.instance.conn }
    let(:error_message) { 'Solr returned an empty response for term query foo_field_sim. Is it configured correctly?' }

    before do
      allow(term).to receive(:solr_connection).and_return(connection)
      allow(connection).to receive(:get).and_return({})
    end

    it 'logs a message and returns and empty array' do
      expect(Rails.logger).to receive(:error).with(error_message)
      expect(term.query).to eq([])
    end
  end

  context 'when Solr cannot process the query' do
    let(:connection) { ActiveFedora::SolrService.instance.conn }
    let(:error_message) { 'Unable to query Solr for the term foo_field_sim: error from rsolr' }

    before do
      allow(term).to receive(:solr_connection).and_raise('error from rsolr')
    end

    it 'logs a message and returns and empty array' do
      expect(Rails.logger).to receive(:error).with(error_message)
      expect(term.query).to eq([])
    end
  end
end
