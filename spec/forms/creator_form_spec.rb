# frozen_string_literal: true

require 'rails_helper'

describe CreatorForm do
  subject { form }

  let(:form) { described_class.new(person_alias) }

  context 'when the alias exists with a person' do
    let(:person_alias) { build(:alias, display_name: 'Joe Bob',
                                       person: build(:person, :with_complete_metadata)) }

    it { is_expected.to be_read_only }
    its(:display_name) { is_expected.to eq('Joe Bob') }
    its(:id) { is_expected.to eq(person_alias.id) }
    its(:given_name) { is_expected.to eq('Johnny C.') }
    its(:sur_name) { is_expected.to eq('Lately') }
    its(:psu_id) { is_expected.to eq('jcl81') }
    its(:email) { is_expected.to eq('newkid@example.com') }
    its(:orcid_id) { is_expected.to eq('00123445') }
  end

  context 'when the alias is new and has no person' do
    let(:person_alias) { build(:alias, display_name: 'Joe Bob') }

    it { is_expected.not_to be_read_only }
    its(:display_name) { is_expected.to eq('Joe Bob') }
    its(:id) { is_expected.to eq(person_alias.id) }
    its(:given_name) { is_expected.to eq('Joe') }
    its(:sur_name) { is_expected.to eq('Bob') }
    its(:psu_id) { is_expected.to be_nil }
    its(:email) { is_expected.to be_nil }
    its(:orcid_id) { is_expected.to be_nil }
  end
end
