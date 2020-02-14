# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::Creator do
  subject { described_class.new(creator_alias) }

  context 'when the alias has an agent' do
    let(:creator_alias) { build(:creator) }

    its(:metadata) do
      is_expected.to include(
        alias: creator_alias.display_name,
        creator_attributes: {
          given_name: creator_alias.agent.given_name,
          surname: creator_alias.agent.sur_name,
          email: creator_alias.agent.email,
          psu_id: creator_alias.agent.psu_id
        }
      )
    end
  end

  context 'when the alias does NOT have an agent' do
    let(:creator_alias) { build(:alias, display_name: 'John Smith') }

    its(:metadata) do
      is_expected.to include(
        alias: creator_alias.display_name,
        creator_attributes: {
          given_name: 'John',
          surname: 'Smith',
          email: nil,
          psu_id: nil
        }
      )
    end
  end
end
