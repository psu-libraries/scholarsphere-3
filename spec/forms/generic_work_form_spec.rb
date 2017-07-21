# frozen_string_literal: true
require "rails_helper"

describe CurationConcerns::GenericWorkForm do
  let(:user)    { create(:user, display_name: "Test A User") }
  let(:ability) { Ability.new(user) }
  let(:work)    { build(:work) }
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

  it_behaves_like "a standard work form"

  describe "#visibility" do
    subject { work }
    context "with an existing work" do
      let(:work) { build(:private_work) }
      before { allow(work).to receive(:new_record?).and_return(false) }
      its(:visibility) { is_expected.to eq("restricted") }
    end
  end

  describe "#target_selector" do
    subject { form.target_selector }
    context "with a new work" do
      it { is_expected.to eq("#new_generic_work") }
    end

    context "when editing an existing work" do
      let(:work) { build(:work, id: "1234") }
      before { allow(work).to receive(:persisted?).and_return(true) }
      it { is_expected.to eq("#edit_generic_work_1234") }
    end
  end

  describe "#select_files" do
    let(:work) { build(:public_work) }

    let(:public_file_set) do
      build(:file_set, :with_file_size, :public, id: "public-fileset", title: ["Public File"])
    end

    let(:registered_file_set) do
      build(:file_set, :with_file_size, :registered, id: "registered-fileset", title: ["Registered File"])
    end

    let(:file_presenters) do
      [
        CurationConcerns::FileSetPresenter.new(SolrDocument.new(public_file_set.to_solr), Ability.new(nil)),
        CurationConcerns::FileSetPresenter.new(SolrDocument.new(registered_file_set.to_solr), Ability.new(nil))
      ]
    end

    before { allow(form).to receive(:file_presenters).and_return(file_presenters) }

    subject { form }
    its(:select_files) { is_expected.to include("Registered File (less visible)", "Public File") }
  end
end
