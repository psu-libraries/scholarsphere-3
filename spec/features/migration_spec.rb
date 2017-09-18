# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Migration', type: :feature do
  let(:collection) { build :collection, id: 'collection_123abc' }
  let(:collection2) { create :collection, title: ['new format'] }
  let(:collection_creator) { 'Collection Creator' }
  let(:work) { build :work, id: 'work_123abc' }
  let(:work2) { create :work, title: ['new format'] }
  let(:work_creator) { 'Work Creator' }
  let(:cache_file) { 'tmp/migrator_cach.txt' }
  let(:sparql_insert) { instance_double(ActiveFedora::SparqlInsert) }

  before do
    # need to allow some calls to fedora to go through normally because we are faking the old records
    allow(Collection).to receive(:find).and_call_original
    allow(GenericWork).to receive(:find).and_call_original
    collection2
    work2

    save_collection_to_solr(collection, collection_creator)
    save_work_to_solr_and_fake_fedora(work, work_creator)
    allow(collection).to receive(:creator_ids).and_return([collection_creator])
    allow(ActiveFedora::SparqlInsert).to receive(:new).and_return(sparql_insert)
    allow(sparql_insert).to receive(:execute)
  end

  after do
    ActiveFedora::Cleaner.cleanout_solr
    FileUtils.rm_f(cache_file)
  end

  describe '#run' do
    subject(:migrator) { Migration::CreatorMigrator.run(cache_file) }

    it 'Calls runs the migration' do
      expect { migrator }.to change { Alias.count }.by(2).and change { Agent.count }.by(2)
    end
  end
end
