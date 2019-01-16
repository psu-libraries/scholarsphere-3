# frozen_string_literal: true

require 'rails_helper'

describe GenericWork do
  subject { work }

  let(:work) { create(:work) }

  it 'creates a noid on save' do
    expect(subject.id.length).to eq 10
  end

  describe 'destroy' do
    let(:user) { create :user }
    let(:work) { create :public_work_with_png, depositor: user.login }
    let(:original_file_url) { work.file_sets.first.original_file.file_path }
    let(:pair_tree) { Scholarsphere::Pairtree.new(work.file_sets.first, nil) }
    let(:content_path) { pair_tree.storage_path(original_file_url) }
    let(:bag_directory) { Pathname(content_path).parent.parent }

    it 'deletes the files in the binary store' do
      expect(File).to be_exist(content_path)
      work.destroy
      expect(File).not_to be_exist(content_path)
      expect(File).not_to be_exist(bag_directory.parent)
      expect(File).to be_exist(bag_directory.parent.parent)
    end
  end

  describe 'creators' do
    before do
      Alias.destroy_all
      Agent.destroy_all
    end

    context 'with existing Alias records' do
      let!(:frodo) { create(:alias, display_name: 'Frodo', agent: Agent.new(given_name: 'Frodo', sur_name: 'Baggins')) }
      let!(:sam)   { create(:alias, display_name: 'Sam', agent: Agent.new(given_name: 'Sam', sur_name: 'Gamgee')) }

      let(:work) { build(:work, creators: [frodo, sam]) }

      it 'sets the creators' do
        expect { work.save! }
          .to change(described_class, :count).by(1)
          .and change(Alias, :count).by(0)
        expect(work.creators).to contain_exactly(frodo, sam)
      end
    end

    context 'with hash inputs' do
      let!(:agent) { create(:agent, given_name: 'Lucy', sur_name: 'Lee') }
      let!(:lucy) { create(:alias, display_name: 'Lucy Lee', agent: agent) }

      let(:work) { create(:work, creators: attributes) }
      let(:attributes) do
        [
          { 'display_name' => 'Fred Jones', 'given_name' => 'Fred', 'sur_name' => 'Jones' },
          { 'display_name' => 'Lucy Lee', 'given_name' => 'Lucy', 'sur_name' => 'Lee' }
        ]
      end

      it 'finds or creates the Alias record' do
        expect { work.save! }
          .to change(described_class, :count).by(1)
          .and change(Alias, :count).by(1)
        expect(work.creators).to include lucy
        expect(work.creators.map(&:display_name)).to contain_exactly('Fred Jones', 'Lucy Lee')
      end
    end

    context 'with ordered, nested-style hash inputs that come from the form' do
      let!(:agent) { create(:agent, given_name: 'Lucy', sur_name: 'Lee') }
      let!(:lucy) { create(:alias, display_name: 'Lucy Lee', agent: agent) }

      let(:work) { create(:work, creators: attributes) }
      let(:attributes) do
        {
          '0' => { 'display_name' => 'Fred Jones', 'given_name' => 'Fred', 'sur_name' => 'Jones' },
          '1' => { 'display_name' => 'Lucy Lee', 'given_name' => 'Lucy', 'sur_name' => 'Lee' }
        }
      end

      it 'finds or creates the Alias record' do
        expect { work.save! }
          .to change(described_class, :count).by(1)
          .and change(Alias, :count).by(1)
        expect(work.creators).to include lucy
        expect(work.creators.map(&:display_name)).to contain_exactly('Fred Jones', 'Lucy Lee')
      end
    end

    # When we changed the work's creators to be an Alias model instead of a String, the name of the method to find the
    # work's creators also changed. It is now 'work.creators' (with an 's') instead of 'work.creator'.
    # Because there are many places in in scholarsphere, sufia, and curation_concerns that call the 'creator' method,
    # we just aliased the method 'creator' to 'creators'.
    context 'calling "creator" method' do
      let!(:frodo) { create(:alias, display_name: 'Frodo', agent: Agent.new(given_name: 'Frodo', sur_name: 'Baggins')) }

      let(:work) { create(:work, creators: [frodo]) }

      it 'returns the creators with no error' do
        expect(work.creators).to eq [frodo]
        expect(work.creator).to eq [frodo]
      end
    end
  end

  describe '#time_uploaded' do
    context 'with a blank date_uploaded' do
      its(:time_uploaded) { is_expected.to be_blank }
    end

    context 'with date_uploaded' do
      before { allow(work).to receive(:date_uploaded).and_return(Date.today) }

      its(:time_uploaded) { is_expected.to eq(Date.today.strftime('%Y-%m-%d %H:%M:%S')) }
    end
  end

  describe '#url' do
    its(:url) { is_expected.to end_with("/concern/generic_works/#{work.id}") }
  end

  describe '::indexer' do
    subject { described_class }

    its(:indexer) { is_expected.to eq(WorkIndexer) }
  end

  describe '#bytes' do
    let(:file_size_field)  { work.send(:file_size_field)  }
    let(:file1)            { build(:file_set, id: 'fs1')  }
    let(:file2)            { build(:file_set, id: 'fs2')  }

    before do
      ActiveFedora::Cleaner.cleanout_solr
      ActiveFedora::SolrService.add(file1.to_solr.merge!(file_size_field.to_sym => '1024'))
      ActiveFedora::SolrService.add(file2.to_solr.merge!(file_size_field.to_sym => '1024'))
      ActiveFedora::SolrService.commit
      allow(work).to receive(:member_ids).and_return(['fs1', 'fs2'])
    end

    its(:bytes) { is_expected.to eq(2048) }
  end

  describe '#upload_set' do
    its(:upload_set) { is_expected.to be_blank }
  end

  describe '#readme_file' do
    context 'with a readme file' do
      let(:file_set) { build(:file_set, label: 'README') }

      before { allow(work).to receive(:file_sets).and_return([file_set]) }

      its(:readme_file) { is_expected.to eq(file_set) }
    end

    context 'with no file sets' do
      its(:readme_file) { is_expected.to be_nil }
    end
  end
end
