# frozen_string_literal: true
shared_examples "a standard work form" do
  describe "#visibility" do
    subject { form }
    context "with a new work" do
      its(:visibility) { is_expected.to eq("open") }
    end
  end
end
