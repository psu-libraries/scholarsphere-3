# frozen_string_literal: true

require 'rails_helper'

describe WorkShowPresenter do
  subject { presenter }

  let(:work)      { build(:work, id: '1234') }
  let(:solr_doc)  { SolrDocument.new(work.to_solr) }
  let(:ability)   { Ability.new(nil) }
  let(:presenter) { described_class.new(solr_doc, ability) }

  describe '#size' do
    before { allow(work).to receive(:bytes).and_return('2048') }
    its(:size) { is_expected.to eq('2 KB') }
  end

  describe '#total_items' do
    context 'with no files in the work' do
      its(:total_items) { is_expected.to eq(0) }
    end

    context 'with two files in the work' do
      let(:solr_doc)    { SolrDocument.new(work.to_solr).to_h.merge!('member_ids_ssim' => ['thing1', 'thing2']) }

      its(:total_items) { is_expected.to eq(2) }
    end
  end

  describe '#member_presenters' do
    subject { presenter.member_presenters }

    let(:work) { create(:public_work, ordered_members: [file_set1, file_set2]) }

    context 'when the current user has read access to all file sets' do
      let(:file_set1) { create(:file_set, :public) }
      let(:file_set2) { create(:file_set, :public) }

      its(:count) { is_expected.to eq(2) }
    end

    context 'when the current user does not have read access to all file sets' do
      let(:file_set1) { create(:file_set, :public) }
      let(:file_set2) { create(:file_set) }

      its(:count) { is_expected.to eq(1) }
    end
  end

  describe '#uploading?' do
    subject { presenter }

    context 'when file sets are in process' do
      before { QueuedFile.create(work_id: '1234') }
      it { is_expected.to be_uploading }
    end

    context 'when no file sets are in process' do
      it { is_expected.not_to be_uploading }
    end
  end

  describe '#facet_mapping' do
    subject { presenter.facet_mapping(:creator_name) }

    let(:work) { build :work }
    let(:creator_alias) { build(:alias, display_name: 'JOE SMITH') }

    before { allow(work).to receive(:creators).and_return([creator_alias]) }

    it { is_expected.to eq('JOE SMITH' => 'Joe Smith') }
  end

  describe '#events' do
    context 'with no events' do
      let(:work)   { build(:work) }

      its(:events) { is_expected.to be_empty }
    end

    context 'with events' do
      let(:events) { double }

      before do
        allow(Sufia::RedisEventStore).to receive(:for).with('GenericWork:1234:event').and_return(events)
        allow(events).to receive(:fetch).with(100).and_return(['event1', 'event2'])
      end

      its(:events) { is_expected.to contain_exactly('event1', 'event2') }
    end
  end

  describe '#creator' do
    context 'verify that the new creator is an alias' do
      let(:solr_doc) { SolrDocument.new('creator_name_tesim' => ['Thomas Jefferson']) }

      its(:creator_name) { is_expected.to eq(['Thomas Jefferson']) }
    end

    context 'verify that the old creator works with the alias' do
      let(:solr_doc) { SolrDocument.new('creator_tesim' => ['Jefferson, Thomas']) }

      its(:creator_name) { is_expected.to eq(['Jefferson, Thomas']) }
    end

    context 'verify that the old creator still exists' do
      let(:solr_doc) { SolrDocument.new('creator_tesim' => ['Jefferson, Thomas']) }

      its(:creator) { is_expected.to eq(['Jefferson, Thomas']) }
    end
  end

  describe '#readme' do
    include FactoryHelpers
    subject { presenter.readme }

    context "when there isn't a readme" do
      it { is_expected.to be_nil }
    end

    context 'when there is a text file' do
      let(:file_set) { create(:file_set, :public, label: 'README.txt') }
      let(:file_set_presenters) { [FileSetPresenter.new(SolrDocument.new(file_set.to_solr), nil)] }
      let(:file) { mock_file_factory(mime_type: 'text/plain', content: 'some readme content for the test') }

      before do
        allow(presenter).to receive(:file_set_presenters).and_return(file_set_presenters)
        allow(file_set).to receive(:original_file).and_return(file)
        allow(FileSet).to receive(:find).with(file_set.id).and_return(file_set)
      end

      it { is_expected.to include '<p>some readme content for the test</p>' }
    end

    context 'when there is a markdown file' do
      let(:file_set) { create(:file_set, :public, label: 'README.md') }
      let(:file_set_presenters) { [FileSetPresenter.new(SolrDocument.new(file_set.to_solr), nil)] }
      let(:file) { mock_file_factory(mime_type: 'text/markdown', content: 'other readme content that is in a markdown file') }

      before do
        allow(presenter).to receive(:file_set_presenters).and_return(file_set_presenters)
        allow(file_set).to receive(:original_file).and_return(file)
        allow(FileSet).to receive(:find).with(file_set.id).and_return(file_set)
      end

      it { is_expected.to include '<p>other readme content that is in a markdown file</p>' }
    end

    context 'when there is a blank readme file' do
      let(:file_set) { create(:file_set, :public, label: 'ReadMe.txt') }
      let(:file_set_presenters) { [FileSetPresenter.new(SolrDocument.new(file_set.to_solr), nil)] }
      let(:file) { mock_file_factory(content: '') }

      before do
        allow(presenter).to receive(:file_set_presenters).and_return(file_set_presenters)
        allow(file_set).to receive(:original_file).and_return(file)
        allow(FileSet).to receive(:find).with(file_set.id).and_return(file_set)
      end

      it { is_expected.to include '' }
    end
  end

  its(:event_class) { is_expected.to eq(GenericWork) }
end
