# frozen_string_literal: true

require 'rails_helper'

describe Migration::SolrListMigrator do
  let(:work1) { build :work, id: '123abc' }
  let(:work2) { build :work, id: '567abc' }
  let(:work3) { build :work, id: '999abc' }
  let(:conn) { ActiveFedora::SolrService.instance.conn }

  let(:creator1) { 'Bugs Bunny' }
  let(:creator2) { 'Bunny, Bugs' }
  let(:creator3) { ['Tweey E Bird', 'Cat, Sylvester', 'Chicken Hawk', 'Wile E Coyote'] }
  let(:alias_hash) { Migration::CreatorList.new(cache_name).to_alias_hash }
  let(:sparql_insert) { instance_double(ActiveFedora::SparqlInsert) }
  let(:cache_name) { 'tmp/my_cahce' }

  before do
    allow(ActiveFedora::SparqlInsert).to receive(:new).and_return(sparql_insert)
    allow(sparql_insert).to receive(:execute)
  end

  # @note The second test fails unless it is run separately. Cleaning out both Fedora and Solr seems to fix this.
  after do
    ActiveFedora::Cleaner.clean!
    FileUtils.rm_f(cache_name)
  end

  describe '#migrate_creators' do
    before do
      save_work_to_solr_and_fake_fedora(work1, creator1)
      save_work_to_solr_and_fake_fedora(work2, creator2)
      save_work_to_solr_and_fake_fedora(work3, creator3)
    end

    subject(:migrator) { described_class.migrate_creators(Migration::SolrWorkList.new, alias_hash) }

    it 'is expected to migrate Aliases' do
      migrator
      expect(work1.creators).to contain_exactly(alias_hash[creator1])
      expect(work2.creators).to contain_exactly(alias_hash[creator2])
      expect(work3.creators).to eq(creator3.map { |creator| alias_hash[creator] })
    end

    context 'missing creator' do
      let(:work4) { build :work, id: '999missing' }
      let(:creator4) { 'After Alias Hash' }

      it 'skips the missing creator' do
        local_alias_hash = alias_hash
        expect(sparql_insert).not_to receive(:execute).with(work4.uri.to_s)
        expect(sparql_insert).to receive(:execute).with(work1.uri.to_s)
        expect(sparql_insert).to receive(:execute).with(work2.uri.to_s)
        expect(sparql_insert).to receive(:execute).with(work3.uri.to_s)

        expect(Rails.logger).to receive(:error).with('Creator alias could not be found for After Alias Hash skipping translation of 999missing')
        save_work_to_solr_and_fake_fedora(work4, creator4)
        described_class.migrate_creators(Migration::SolrWorkList.new, local_alias_hash)
        expect(work1.creators).to contain_exactly(alias_hash[creator1])
        expect(work2.creators).to contain_exactly(alias_hash[creator2])
        expect(work3.creators).to eq(creator3.map { |creator| alias_hash[creator] })
      end
    end
  end

  describe '#update' do
    before do
      save_work_to_solr_and_fake_fedora(work1, creator1)
    end

    it 'sets the creators' do
      work1.admin_set = nil
      alias_hash
      expect(work1.admin_set).to be_nil
      described_class.update(work1, {})
      expect(work1.creators).to contain_exactly(alias_hash[creator1])
      expect(work1.admin_set.id).to eq(AdminSet::DEFAULT_ID)
    end
  end
end
