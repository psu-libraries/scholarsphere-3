# frozen_string_literal: true
require "rails_helper"

describe BatchUploadForm do
  let(:user)    { create(:user, display_name: "Test A User") }
  let(:ability) { Ability.new(user) }
  let(:form)    { described_class.new(BatchUploadItem.new, ability) }

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

  describe "#model_attributes" do
    subject { described_class.model_attributes(raw_attrs) }
    let(:raw_attrs) { ActionController::Parameters.new("creator" => ["Santy, Lorraine C", ""], "keyword" => ["hhh"], "rights" => "https://creativecommons.org/licenses/by/4.0/", "description" => ["ghjg"], "contributor" => [""], "publisher" => [""], "date_created" => [""], "subject" => [""], "language" => [""], "identifier" => [""], "based_near" => [""], "related_url" => [""], "source" => [""], "admin_set_id" => "", "collection_ids" => [""], "visibility_during_embargo" => "restricted", "embargo_release_date" => "2017-01-24", "visibility_after_embargo" => "open", "visibility_during_lease" => "open", "lease_expiration_date" => "2017-01-24", "visibility_after_lease" => "restricted", "visibility" => "restricted") }
    it { is_expected.to eq("creator" => ["Santy, Lorraine C"], "keyword" => ["hhh"], "rights" => "https://creativecommons.org/licenses/by/4.0/", "description" => ["ghjg"], "contributor" => [], "publisher" => [], "date_created" => [], "subject" => [], "language" => [], "identifier" => [], "based_near" => [], "related_url" => [], "source" => [], "admin_set_id" => "", "collection_ids" => [], "visibility_during_embargo" => "restricted", "embargo_release_date" => "2017-01-24", "visibility_after_embargo" => "open", "visibility_during_lease" => "open", "lease_expiration_date" => "2017-01-24", "visibility_after_lease" => "restricted", "visibility" => "restricted") }
  end

  describe "#target_selector" do
    subject { form.target_selector }
    it { is_expected.to eq("#new_batch_upload_item") }
  end

  it_behaves_like "a standard work form"
end
