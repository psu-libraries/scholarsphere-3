# frozen_string_literal: true
require 'rails_helper'

describe CurationConcerns::GenericWorkForm do
  let(:user)    { create(:user, display_name: "Test A User") }
  let(:ability) { Ability.new(user) }
  let(:work)    { GenericWork.new }
  let(:form)    { described_class.new(work, ability) }
  describe "#initialize_field" do
    subject { form[:creator] }
    it { is_expected.to eq(["User, Test A"]) }
  end

  describe "::model_attributes" do
    subject { described_class.model_attributes(params) }
    context "when attributes have multiple spaces" do
      let(:params) { ActionController::Parameters.new(title: [" I am  in a  space "], rights: " url ") }
      it { is_expected.to include(title: ["I am in a space"], rights: "url") }
    end
  end
end
