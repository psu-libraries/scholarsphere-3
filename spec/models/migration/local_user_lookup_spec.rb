# frozen_string_literal: true

require 'rails_helper'

describe Migration::LocalUserLookup, type: :model do
  subject { described_class.find_users(search_name).map(&:display_name) }

  before do
    User.create!(login: 'abc@psu.edu', display_name: 'Abc 123')
    User.create!(login: 'abc2@psu.edu', display_name: 'Abc two 123')
    User.create!(login: 'kermit@pong.log', display_name: 'Kermit The Frog')
  end

  let(:search_name) { 'abc' }

  it { is_expected.to contain_exactly('Abc 123', 'Abc two 123') }

  context 'multiple name parts' do
    let(:search_name) { 'abc 123' }

    it { is_expected.to contain_exactly('Abc 123', 'Abc two 123') }

    context 'with an initial' do
      let(:search_name) { 'abc t 123' }

      it { is_expected.to contain_exactly('Abc two 123') }
    end

    context 'with a different initial' do
      let(:search_name) { 'abc b 123' }

      it { is_expected.to be_empty }
    end

    context 'with the name mixed around' do
      let(:search_name) { '123 abc t' }

      it { is_expected.to contain_exactly('Abc two 123') }
    end

    context 'with the name mixed around and punctuation' do
      let(:search_name) { '123, abc t.' }

      it { is_expected.to contain_exactly('Abc two 123') }
    end
  end
end
