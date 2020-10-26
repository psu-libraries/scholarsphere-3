# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::Identifier, type: :model do
  subject { described_class.new(identifiers) }

  context 'when there are no identifiers' do
    let(:identifiers) { [] }

    its(:other) { is_expected.to be_empty }
    its(:doi) { is_expected.to be_nil }
  end

  context 'when there are no dois' do
    let(:identifiers) { ['not-a-doi'] }

    its(:other) { is_expected.to contain_exactly('not-a-doi') }
    its(:doi) { is_expected.to be_nil }
  end

  context 'with a doi in the 18113 namespace' do
    let(:identifiers) { ['not-a-doi', 'https://doi.org/10.18113/S1KW2H'] }

    its(:other) { is_expected.to contain_exactly('not-a-doi') }
    its(:doi) { is_expected.to eq('https://doi.org/10.18113/S1KW2H') }
  end

  context 'with a doi in the 26207 namespace' do
    let(:identifiers) { ['not-a-doi', 'doi:10.26207/kqbb-db45'] }

    its(:other) { is_expected.to contain_exactly('not-a-doi') }
    its(:doi) { is_expected.to eq('doi:10.26207/kqbb-db45') }
  end

  context 'with an unsupported doi' do
    let(:identifiers) { ['not-a-doi', '10.1038/srep21619'] }

    its(:other) { is_expected.to contain_exactly('not-a-doi', '10.1038/srep21619') }
    its(:doi) { is_expected.to be_nil }
  end

  context 'with multiple dois' do
    let(:identifiers) { ['doi:10.26207/76jf-gb12', 'doi:10.26207/ampx-ph42', 'doi:10.26207/6yn8-p715'] }

    its(:other) { is_expected.to contain_exactly('doi:10.26207/ampx-ph42', 'doi:10.26207/6yn8-p715') }
    its(:doi) { is_expected.to eq('doi:10.26207/76jf-gb12') }
  end
end
