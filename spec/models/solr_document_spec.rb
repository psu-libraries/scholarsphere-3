# frozen_string_literal: true

require 'rails_helper'

describe SolrDocument do
  subject { described_class.new(resource.to_solr) }

  context 'with a work' do
    let(:resource) { build(:work, id: 'foo') }

    describe '#export_as_endnote' do
      let(:export) do
        "%0 Work\n" \
        "%T Sample Title\n" \
        "%R http://scholarsphere.psu.edu/files/#{resource.id}\n" \
        "%~ ScholarSphere\n" \
        '%W Penn State'
      end

      its(:export_as_endnote) { is_expected.to eq(export) }
    end

    describe '#file_size' do
      subject { described_class.new(file_size_lts: ['1234']) }

      its(:file_size) { is_expected.to eq('1234') }
    end

    describe '#bytes' do
      subject { described_class.new(bytes_lts: ['1234']) }

      its(:bytes) { is_expected.to eq('1234') }
    end

    describe '#to_hash' do
      its(:to_hash) { is_expected.to eq(subject.to_h) }
    end
  end

  context 'with a person' do
    let(:resource) { build(:person, :with_metadata) }

    its(:given_name) { is_expected.to eq('John Q.') }
    its(:sur_name) { is_expected.to eq('Metadata') }
    its(:psu_id) { is_expected.to eq('jqm123') }
    its(:orcid_id) { is_expected.to eq('123456789') }
  end
end
