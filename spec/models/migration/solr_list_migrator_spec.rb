# frozen_string_literal: true

require 'rails_helper'

describe Migration::SolrListMigrator do
  let(:work1) { build :work, id: '123abc' }
  let(:work2) { build :work, id: '567abc' }
  let(:work3) { build :work, id: '999abc' }
  let(:conn) { ActiveFedora::SolrService.instance.conn }

  let(:creator1) { 'Bugs Bunny' }
  let(:creator2) { 'Bunny, Bugs' }
  let(:creator3) { 'Tweey E Bird' }
  let(:alias_hash) { Migration::CreatorList.new(cache_name).to_alias_hash }
  let(:sparql_insert) { instance_double(ActiveFedora::SparqlInsert) }

  before do
    allow(ActiveFedora::SparqlInsert).to receive(:new).and_return(sparql_insert)
    allow(sparql_insert).to receive(:execute)
  end

  describe '#uniq_system_creators' do
    before do
      save_work_to_solr_and_fake_fedora(work1, creator1)
      save_work_to_solr_and_fake_fedora(work2, creator2)
      save_work_to_solr_and_fake_fedora(work3, creator3)
    end
    after do
      ActiveFedora::Cleaner.cleanout_solr
      FileUtils.rm_f(cache_name)
    end

    subject(:migrator) { described_class.migrate_creators(Migration::SolrWorkList.new, alias_hash) }

    let(:cache_name) { 'tmp/my_cahce' }

    it 'is expected to migrate Aliases' do
      migrator
      expect(work1.creator).to contain_exactly(alias_hash[creator1])
      expect(work2.creator).to contain_exactly(alias_hash[creator2])
      expect(work3.creator).to contain_exactly(alias_hash[creator3])
    end
  end
end
