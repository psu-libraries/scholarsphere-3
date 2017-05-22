# frozen_string_literal: true
require 'rails_helper'

describe "curation_concerns/base/_form.html.erb" do
  include Devise::Test::ControllerHelpers

  let(:form) { CurationConcerns::GenericWorkForm.new(GenericWork.new, Ability.new(nil)) }

  before do
    assign(:form, form)
    controller.stub(:params).and_return(params)
    stub_template "_form_files.html.erb" => ""
    stub_template "_form_metadata.html.erb" => ""
    stub_template "_form_relationships.html.erb" => ""
    stub_template "_form_share.html.erb" => ""
    stub_template "_form_progress.html.erb" => ""
    render "curation_concerns/base/form.html.erb"
  end

  describe "rendering the link that switches to the batch create page" do
    subject { rendered }

    context "without no collection id parameters" do
      let(:params) { {} }
      it { is_expected.to include('href="/batch_uploads/new"') }
    end

    context "with collection ids" do
      let(:params) { { collection_ids: ["collection-id"] } }
      it { is_expected.to include('href="/batch_uploads/new?collection_ids%5B%5D=collection-id"') }
    end
  end
end
