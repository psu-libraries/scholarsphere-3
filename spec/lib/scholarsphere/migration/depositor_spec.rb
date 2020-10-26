# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::Depositor do
  subject(:depositor) { described_class.new(login: user.login) }

  context 'when the depositor has both a User and Agent record but no SearchService record (the most typical case)' do
    let(:agent) { create(:agent, :from_psu, :with_orcid_id) }
    let(:user) { create(:user, login: agent.psu_id, display_name: Faker::Name.name) }

    its(:user) { is_expected.to be_a(User) }
    its(:agent) { is_expected.to be_an(Agent) }
    its(:person) { is_expected.to be_a(Scholarsphere::Migration::Depositor::NullPerson) }

    it 'prefers the Agent record over the User record' do
      expect(depositor.send(:given_name)).not_to eq(depositor.agent.given_name)
      expect(depositor.send(:surname)).not_to eq(depositor.agent.sur_name)
      expect(depositor.metadata).to eq(
        psu_id: user.login,
        email: agent.email,
        given_name: agent.given_name,
        surname: agent.sur_name
      )
    end
  end

  context 'when the depositor has all three: User, Agent, and SearchService', unless: travis? do
    let(:user) { create(:user, login: 'dmc186', display_name: Faker::Name.name) }

    before do
      create(:agent, psu_id: user.login, given_name: Faker::Name.first_name, sur_name: Faker::Name.last_name)
    end

    its(:user) { is_expected.to be_a(User) }
    its(:agent) { is_expected.to be_an(Agent) }
    its(:person) { is_expected.to be_a(PennState::SearchService::Person) }

    it 'prefers the SearchService record over the others' do
      expect(depositor.send(:given_name)).not_to eq(depositor.person.given_name)
      expect(depositor.send(:surname)).not_to eq(depositor.person.family_name)
      expect(depositor.agent.given_name).not_to eq(depositor.person.given_name)
      expect(depositor.agent.sur_name).not_to eq(depositor.person.family_name)

      expect(depositor.metadata).to eq(
        psu_id: user.login,
        email: 'dmc186@psu.edu',
        given_name: 'Daniel',
        surname: 'Coughlin'
      )
    end
  end

  context 'when the depositor has only the User record' do
    let(:given_name) { Faker::Name.first_name }
    let(:surname) { Faker::Name.last_name }
    let(:user) { create(:user, display_name: "#{given_name} #{surname}", email: Faker::Internet.email) }

    its(:user) { is_expected.to be_a(User) }
    its(:agent) { is_expected.to be_a(Scholarsphere::Migration::Depositor::NullAgent) }
    its(:person) { is_expected.to be_a(Scholarsphere::Migration::Depositor::NullPerson) }

    its(:metadata) do
      is_expected.to eq(
        psu_id: user.login,
        email: user.email,
        given_name: given_name,
        surname: surname
      )
    end

    context 'with a last name only in the display name' do
      let(:surname) { Faker::Name.last_name }
      let(:user) { create(:user, display_name: surname, email: Faker::Internet.email) }

      its(:metadata) do
        is_expected.to eq(
          psu_id: user.login,
          email: user.email,
          given_name: nil,
          surname: surname
        )
      end
    end

    context 'with an empty display name' do
      let(:user) { create(:user, display_name: nil, email: Faker::Internet.email) }

      its(:metadata) do
        is_expected.to eq(
          psu_id: user.login,
          email: user.email,
          given_name: nil,
          surname: user.login
        )
      end
    end
  end
end
