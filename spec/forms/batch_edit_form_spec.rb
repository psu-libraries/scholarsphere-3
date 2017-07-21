# frozen_string_literal: true
require "rails_helper"

describe BatchEditForm do
  describe "::build_permitted_params" do
    subject { described_class }
    its(:build_permitted_params) { is_expected.to include(:visibility) }
  end
end
