# frozen_string_literal: true

require 'rails_helper'

describe Migration::CreatorMigrator do
  let(:collection) { build :collection, id: 'collection_123abc' }
  let(:collection_creator) { 'Collection Creator' }
  let(:work) { build :work, id: 'work_123abc' }
  let(:work_creator) { 'Work Creator' }
  let(:cache_file) { 'tmp/migrator_cach.txt' }
  let(:sparql_insert) { instance_double(ActiveFedora::SparqlInsert) }

  before do
    save_collection_to_solr(collection, collection_creator)
    save_work_to_solr_and_fake_fedora(work, work_creator)
    allow(ActiveFedora::SparqlInsert).to receive(:new).and_return(sparql_insert)
    allow(sparql_insert).to receive(:execute)
  end

  after do
    ActiveFedora::Cleaner.cleanout_solr
    FileUtils.rm_f(cache_file)
  end

  describe '#run' do
    subject(:migrator) { described_class.run(cache_file) }

    it 'Calls runs the migration' do
      expect { migrator }.to change(Alias, :count).by(2).and change(Agent, :count).by(2)
    end
  end
end
