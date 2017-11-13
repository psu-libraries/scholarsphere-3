# frozen_string_literal: true

require 'rails_helper'

describe Migration::SolrCollectionList, clean: true do
  subject { described_class.new.objects }

  let(:collection)  { build :collection, id: '123abc' }
  let(:collection2) { build :collection, id: '567abc' }
  let(:collection3) { build :collection, id: '999abc' }
  let(:conn) { ActiveFedora::SolrService.instance.conn }

  before do
    save_collection_to_solr(collection, 'abc for me')
    save_collection_to_solr(collection2, 'abc for me')
    save_collection_to_solr(collection3, 'abc for me too')
  end
  after do
    ActiveFedora::Cleaner.cleanout_solr
  end

  it { is_expected.to contain_exactly(collection.id, collection2.id, collection3.id) }
end
