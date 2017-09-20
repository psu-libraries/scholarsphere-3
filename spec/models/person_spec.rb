# frozen_string_literal: true

require 'rails_helper'

describe Person do
  subject { build(:person, given_name: 'Given Name', sur_name: 'Sur Name', aliases: [aliaz]) }

  let(:aliaz) { build(:alias) }

  describe '#given_name' do
    its(:given_name) { is_expected.to eq('Given Name') }
  end

  describe '#sur_name' do
    its(:sur_name) { is_expected.to eq('Sur Name') }
  end

  describe '#aliases' do
    its(:aliases) { is_expected.to contain_exactly(aliaz) }
  end
end
