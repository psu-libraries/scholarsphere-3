# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::DepositorsReport, unless: travis? do
  describe '#depositors' do
    let(:user) { create(:user) }

    context 'by default' do
      subject(:depositors) { described_class.new.depositors.keys }

      it { is_expected.to be_empty }
    end

    context 'with a list of arguments' do
      subject(:depositors) { described_class.new(user.login).depositors.keys }

      it { is_expected.to contain_exactly(user.login) }
    end
  end
end
