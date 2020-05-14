# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::Permissions, type: :model do
  subject { described_class.new(resource) }

  context 'when there are other read users' do
    let(:depositor) { build(:user) }
    let(:resource) { build(:work, depositor: depositor.login, read_users: ['somebody', depositor.login]) }

    its(:attributes) do
      is_expected.to eq(
        'read_users' => ['somebody'],
        'read_groups' => [],
        'edit_users' => [],
        'edit_groups' => []
      )
    end
  end

  context 'when there are other edit users' do
    let(:depositor) { build(:user) }
    let(:resource) { build(:work, depositor: depositor.login, edit_users: ['somebody', depositor.login]) }

    its(:attributes) do
      is_expected.to eq(
        'read_users' => [],
        'read_groups' => [],
        'edit_users' => ['somebody'],
        'edit_groups' => []
      )
    end
  end

  context 'with a public resource' do
    let(:resource) { build(:public_work) }

    its(:attributes) do
      is_expected.to eq(
        'read_users' => [],
        'read_groups' => [],
        'edit_users' => [],
        'edit_groups' => []
      )
    end
  end

  context 'with an authorized resource' do
    let(:resource) { build(:registered_work) }

    its(:attributes) do
      is_expected.to eq(
        'read_users' => [],
        'read_groups' => [],
        'edit_users' => [],
        'edit_groups' => []
      )
    end
  end

  context 'with a private work' do
    let(:resource) { build(:private_work) }

    its(:attributes) do
      is_expected.to eq(
        'read_users' => [],
        'read_groups' => [],
        'edit_users' => [],
        'edit_groups' => []
      )
    end
  end
end
