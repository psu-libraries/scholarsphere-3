# frozen_string_literal: true

require 'rails_helper'

describe Migration::CreatorList do
  let(:work) { build :work, id: '123abc' }
  let(:work2) { build :work, id: '567abc' }
  let(:work3) { build :work, id: '999abc' }
  let(:conn) { ActiveFedora::SolrService.instance.conn }

  describe '#uniq_system_creators' do
    before do
      save_work_to_solr_and_fake_fedora(work, 'abc for me')
      save_work_to_solr_and_fake_fedora(work2, 'abc for me')
      save_work_to_solr_and_fake_fedora(work3, 'abc for me too')
    end
    after do
      conn.delete_by_id work.id
      conn.delete_by_id work2.id
      conn.delete_by_id work3.id
      conn.commit
    end

    subject { described_class.new.uniq_system_creators }

    it { is_expected.to eq ['abc for me', 'abc for me too'] }
  end

  describe '#to_alias_hash' do
    subject(:creator_list) { described_class.new(cache_name).to_alias_hash }

    let(:user) { create :user, display_name: 'Frog, Kermit The' }
    let(:work4) { build :work, id: '999zzz' }
    let(:work5) { build :work, id: '999idid' }
    let(:cache_name) { 'tmp/test_cache.txt' }
    let(:agent1) { Agent.new(sur_name: 'blarg institution for the insane') }
    let(:alias1) { Alias.new(id: 'alias1', display_name: 'blarg institution for the insane', agent: agent1) }
    let(:agent2) { Agent.new(sur_name: 'Frog', given_name: 'Kermit The') }
    let(:alias2) { Alias.new(id: 'alias2', display_name: 'Kermit The Frog', agent: agent2) }
    let(:alias3) { Alias.new(id: 'alias3', display_name: user.login, agent: agent2) }

    before do
      user
      allow(Agent).to receive(:create).with(sur_name: 'blarg institution for the insane', given_name: nil).and_return(agent1)
      allow(Agent).to receive(:create).with(sur_name: 'Frog', given_name: 'Kermit The', psu_id: user.login, email: user.email).and_return(agent2)
      allow(Alias).to receive(:create).with(display_name: 'blarg institution for the insane', agent: agent1).and_return(alias1).once
      allow(Alias).to receive(:create).with(display_name: 'Kermit The Frog', agent: agent2).and_return(alias2).once
      allow(Alias).to receive(:create).with(display_name: user.login, agent: agent2).and_return(alias3).once
      save_work_to_solr_and_fake_fedora(work, 'blarg institution for the insane')
      save_work_to_solr_and_fake_fedora(work4, 'Kermit The Frog')
      save_work_to_solr_and_fake_fedora(work5, user.login)
    end
    after do
      ActiveFedora::Cleaner.cleanout_solr
      FileUtils.rm_f(cache_name)
    end

    it { is_expected.to eq('blarg institution for the insane' => alias1,
                           user.login => alias3,
                           'Kermit The Frog' => alias2) }

    context 'Alias Exists' do
      before do
        alias1.save
        alias2.save
        alias3.save
      end

      after do
        alias1.delete(eradicate: true)
        alias2.delete(eradicate: true)
        alias3.delete(eradicate: true)
      end

      it 'is not created again' do
        expect(Alias).not_to receive(:create).with(display_name: 'blarg institution for the insane', agent: agent1)
        expect(Alias).not_to receive(:create).with(display_name: 'Kermit The Frog', agent: agent2)
        expect(Alias).not_to receive(:create).with(display_name: user.login, agent: agent2)
        creator_list
      end
    end

    it 'creates a cache and loads it' do
      creator_list
      expect(File).to be_exist(cache_name)
      expect(Alias).to receive(:find).with(alias1.id).and_return(alias1)
      expect(Alias).to receive(:find).with(alias2.id).and_return(alias2)
      expect(Alias).to receive(:find).with(alias3.id).and_return(alias3)
      expect(Migration::LocalUserLookup).not_to receive(:find_users)
      described_class.new(cache_name).to_alias_hash
    end

    context 'test a Agent' do
      let(:work_test) { build :work, id: '999testAgent' }
      let(:agent_test) { Agent.new(sur_name: sur_name, given_name: given_name) }
      let(:alias_test) { Alias.new(id: 'alias_test', display_name: display_name, agent: agent_test) }

      before do
        allow(Agent).to receive(:create).with(sur_name: sur_name, given_name: given_name).and_return(agent_test)
        allow(Alias).to receive(:create).with(display_name: display_name, agent: agent_test).and_return(alias_test)
        save_work_to_solr_and_fake_fedora(work_test, display_name)
      end

      context 'display name is a partial name match' do
        let(:sur_name) { 'og' }
        let(:given_name) {}
        let(:display_name) { sur_name }

        it { is_expected.to eq('blarg institution for the insane' => alias1,
                               user.login => alias3,
                               'Kermit The Frog' => alias2,
                               display_name => alias_test) }
      end

      context 'display name is a partial name match' do
        let(:sur_name) { 'Frog' }
        let(:given_name) { 'T.' }
        let(:display_name) { "#{given_name} #{sur_name}" }

        it { is_expected.to eq('blarg institution for the insane' => alias1,
                               user.login => alias3,
                               'Kermit The Frog' => alias2,
                               display_name => alias_test) }
      end

      context 'display name is a partial name match' do
        let(:sur_name) { 'Frog' }
        let(:given_name) {}
        let(:display_name) { sur_name }

        it { is_expected.to eq('blarg institution for the insane' => alias1,
                               user.login => alias3,
                               'Kermit The Frog' => alias2,
                               display_name => alias_test) }
      end

      context 'display name is a backward name match' do
        let(:sur_name) { 'Kermit the' }
        let(:given_name) { 'Frog' }
        let(:display_name) { 'Frog Kermit the' }

        before do
          allow(Alias).to receive(:create).with(display_name: display_name, agent: agent2).and_return(alias_test)
        end

        it { is_expected.to eq('blarg institution for the insane' => alias1,
                               user.login => alias3,
                               'Kermit The Frog' => alias2,
                               display_name => alias_test) }
      end
    end
  end

  context 'alias with institution' do
    subject(:creator_list) { described_class.new(cache_name).to_alias_hash }

    let(:work) { build :work, id: '999maps' }
    let(:agent) { Agent.new(sur_name: 'blarg institution for the insane') }
    let(:agent_alias) { Alias.new(id: 'alias1', display_name: 'blarg institution for the insane', agent: agent) }
    let(:cache_name) { 'tmp/test_cache.txt' }

    before do
      allow(Agent).to receive(:create).with(sur_name: 'maps', given_name: nil).and_return(agent)
      allow(Alias).to receive(:create).with(display_name: 'maps', agent: agent).and_return(agent_alias)
      save_work_to_solr_and_fake_fedora(work, 'maps')
    end
    after do
      ActiveFedora::Cleaner.cleanout_solr
      FileUtils.rm_f(cache_name)
    end

    it { is_expected.to eq('maps' => agent_alias) }
  end
end
