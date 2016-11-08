# frozen_string_literal: true
require 'rails_helper'

describe CurationConcerns::GenericWorkForm do
  let(:user)     { create(:user, display_name: "Test A User") }
  let(:ability)  { Ability.new(user) }
  let(:form) { described_class.new(GenericWork.new, ability) }
  describe "#initialize_field" do
    subject { form[:creator] }
    it { is_expected.to eq(["User, Test A"]) }
  end
end
