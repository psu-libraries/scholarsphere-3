# frozen_string_literal: true

require 'rails_helper'

describe CreatorForm do
  subject { form }

  let(:form) { described_class.new(aliaz) }

  context 'when the alias exists with a person' do
    let(:aliaz) { build(:alias, display_name: 'Joe Bob',
                                person: Person.new(sur_name: 'Bob', given_name: 'Joe')) }

    it { is_expected.to be_read_only_name }
    its(:display_name) { is_expected.to eq('Joe Bob') }
    its(:id) { is_expected.to eq(aliaz.id) }
    its(:given_name) { is_expected.to eq('Joe') }
    its(:sur_name) { is_expected.to eq('Bob') }
  end

  context 'when the alias is new and has no person' do
    let(:aliaz) { build(:alias, display_name: 'Joe Bob') }

    it { is_expected.not_to be_read_only_name }
    its(:display_name) { is_expected.to eq('Joe Bob') }
    its(:id) { is_expected.to eq(aliaz.id) }
    its(:given_name) { is_expected.to eq('Joe') }
    its(:sur_name) { is_expected.to eq('Bob') }
  end
end
