require 'spec_helper'

describe BatchController, type: :controller do
  routes { Sufia::Engine.routes }
  let(:subject) { described_class.new }
  let(:current_user) { User.new(display_name: "ALBERT EDWARD MATYASOVSKY JR") }
  let(:batch) { Batch.new }

  describe "#edit_form" do
    before do
      allow(subject).to receive(:current_user).and_return(current_user)
      subject.instance_variable_set("@batch", batch)
    end
    it "creates an edit form with the creator in last name first ordering" do
      expect(subject.edit_form[:creator]).to eq(["Matyasovsky, Jr, Albert Edward"])
    end
  end
end
