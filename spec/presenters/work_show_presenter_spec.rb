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
    let(:creator_alias1) { build(:alias, display_name: 'JOE SMITH', agent: sally) }
    let(:creator_alias2) { build(:alias, display_name: 'JANE SMITH', agent: sally) }
    let(:creator_alias3) { build(:alias, display_name: 'JOHN JACOB SMITH', agent: john) }
    let(:sally) { create(:agent, given_name: 'Sally', sur_name: 'James') }
    let(:john) { create(:agent, given_name: 'John', sur_name: 'Smith') }

    before do
      allow(work).to receive(:creators).and_return([creator_alias1, creator_alias2, creator_alias3])
    end

    it { is_expected.to eq('JOE SMITH' => 'Sally James', 'JANE SMITH' => 'Sally James', 'JOHN JACOB SMITH' => 'John Smith') }

    context 'for a keyword' do
      subject { presenter.facet_mapping(:keyword) }

      let(:work) { build :work, keyword: ['ABC'] }

      it { is_expected.to eq('ABC' => 'abc') }
    end

    context 'for a publisher' do
      subject { presenter.facet_mapping(:publisher) }

      let(:work) { build :work, publisher: ['PUBLISHER'] }

      it { is_expected.to eq('PUBLISHER' => 'Publisher') }
    end
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
    subject { presenter.readme }

    before { allow(presenter).to receive(:readme_file).and_return(readme_content) }

    context 'when there is text' do
      let(:readme_content) { 'some readme content for the test' }

      it { is_expected.to include '<p>some readme content for the test</p>' }
    end

    context 'when there is markdown' do
      let(:readme_content) { '# other readme content that is in a markdown file' }

      it { is_expected.to include '<h1>other readme content that is in a markdown file</h1>' }
    end

    context 'when there is a blank readme file' do
      let(:readme_content) { '' }

      it { is_expected.to include '' }
    end

    context 'when there is no content in the readme file' do
      let(:readme_content) { nil }

      it { is_expected.to be_nil }
    end
  end

  its(:event_class) { is_expected.to eq(GenericWork) }

  describe '#zip_available?' do
    before { allow(presenter).to receive(:bytes).and_return(bytes) }

    context 'when the files are still being uploaded' do
      let(:bytes) { 0 }

      before { allow(presenter).to receive(:uploading?).and_return(true) }

      it { is_expected.not_to be_zip_available }
    end

    context 'when the work is smaller than the zip file size threshold' do
      let(:bytes) { 10 }

      it { is_expected.to be_zip_available }
    end

    context 'when the work is larger than the zip file size threshold and the file is present' do
      let(:bytes) { ScholarSphere::Application.config.zipfile_size_threshold + 100 }

      before { FileUtils.touch(ScholarSphere::Application.config.public_zipfile_directory.join("#{work.id}.zip")) }

      after { FileUtils.rm_f(ScholarSphere::Application.config.public_zipfile_directory.join("#{work.id}.zip")) }

      it { is_expected.to be_zip_available }
    end

    context 'when the work is larger than the zip file size threshold and the file is not present' do
      let(:bytes) { ScholarSphere::Application.config.zipfile_size_threshold + 100 }

      it { is_expected.not_to be_zip_available }
    end
  end
end
