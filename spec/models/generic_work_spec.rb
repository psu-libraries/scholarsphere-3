# frozen_string_literal: true

require 'rails_helper'

describe GenericWork do
  subject { work }

  let(:work) { create(:work) }

  it 'creates a noid on save' do
    expect(subject.id.length).to eq 10
  end

  describe 'creators' do
    before { Person.destroy_all }

    context 'with existing Person records' do
      let(:work) { build(:work, creators: [frodo, sam]) }
      let!(:frodo) { create(:person, first_name: 'Frodo') }
      let!(:sam) { create(:person, first_name: 'Sam') }

      it 'sets the creators' do
        expect { work.save! }
          .to change { described_class.count }.by(1)
          .and change { Person.count }.by(0)
        expect(work.creators).to contain_exactly(frodo, sam)
      end
    end

    context 'building a creator' do
      let(:work) { build(:work) }

      it 'creates a Person record' do
        work.creators.build(first_name: 'Frodo')
        expect { work.save! }
          .to change { described_class.count }.by(1)
          .and change { Person.count }.by(1)
        expect(work.creators.map(&:first_name)).to eq ['Frodo']
        expect(Person.first.first_name).to eq 'Frodo'
      end
    end

    context 'with hash inputs' do
      let(:work) { create(:work, creators: attributes) }
      let(:attributes) do
        [{ 'first_name' => 'Fred', 'last_name' => 'Jones' },
         { 'first_name' => 'Lucy', 'last_name' => 'Lee' }]
      end
      let!(:lucy) { create(:person, first_name: 'Lucy', last_name: 'Lee') } # Record for Lucy already exists

      it 'finds or creates the Person record' do
        expect { work.save! }
          .to change { described_class.count }.by(1)
          .and change { Person.count }.by(1)
        expect(work.creators).to include lucy
        expect(work.creators.map(&:first_name)).to contain_exactly('Fred', 'Lucy')
      end
    end

    # This style of inputs comes from the form
    context 'with nested hash inputs' do
      let(:work) { create(:work, creators: attributes) }
      let(:attributes) do
        {
          '0' => { 'first_name' => 'Fred', 'last_name' => 'Jones' },
          '1' => { 'first_name' => 'Lucy', 'last_name' => 'Lee' }
        }
      end
      let!(:lucy) { create(:person, first_name: 'Lucy', last_name: 'Lee') } # Record for Lucy already exists

      it 'finds or creates the Person record' do
        expect { work.save! }
          .to change { described_class.count }.by(1)
          .and change { Person.count }.by(1)
        expect(work.creators).to include lucy
        expect(work.creators.map(&:first_name)).to contain_exactly('Fred', 'Lucy')
      end
    end

    # When we changed the work's creators to be a Person model instead of a String, the name of the method to find the work's creators also changed.  It is now 'work.creators' (with an 's') instead of 'work.creator'.  But, there are many places in in scholarsphere, sufia, and curation_concerns that call the 'creator' method, so we need to make sure that method exists.  So we just aliased the method 'creator' to 'creators'.
    context 'calling "creator" method' do
      let(:work) { create(:work, creators: [frodo]) }
      let!(:frodo) { create(:person, first_name: 'Frodo') }

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
end
