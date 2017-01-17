# frozen_string_literal: true
require 'rails_helper'

describe BatchUploadForm do
  let(:user)    { create(:user, display_name: "Test A User") }
  let(:ability) { Ability.new(user) }
  let(:form)    { described_class.new(GenericWork.new, ability) }

  describe "::required_fields" do
    subject { described_class }

    its(:required_fields) { is_expected.to contain_exactly(:title,
                                                           :creator,
                                                           :keyword,
                                                           :rights,
                                                           :description) }
  end

  describe "#initialize_field" do
    subject { form[:creator] }
    it { is_expected.to eq(["User, Test A"]) }
  end
end
