# frozen_string_literal: true
require 'rails_helper'

describe "curation_concerns/base/_items.html.erb", verify_partial_doubles: false do
  let(:user)        { create(:user) }
  let(:solr_doc)    { SolrDocument.new(build(:work, id: "1234").to_solr) }
  let(:ability)     { Ability.new(user) }
  let(:presenter)   { WorkShowPresenter.new(solr_doc, ability) }
  let(:queued_file) { QueuedFile.create(work_id: presenter.id, file_id: "1") }

  subject { Capybara::Node::Simple.new(rendered) }

  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
  end

  context "when the user has edit rights" do
    before { allow(ability).to receive(:can?).with(:edit, presenter.id).and_return(true) }

    context "without files" do
      context "without uploads" do
        before { render "curation_concerns/base/items.html.erb", presenter: presenter }
        it { is_expected.to have_content("This Work has no files associated with it.") }
      end

      context "with uploads" do
        before do
          allow(presenter).to receive(:uploading?).and_return(true)
          allow(presenter).to receive(:queued_files).and_return([queued_file])
          render "curation_concerns/base/items.html.erb", presenter: presenter
        end
        it { is_expected.to have_content("Uploading in progress") }
      end
    end
  end

  context "when the user does not have edit rights" do
    before { allow(ability).to receive(:can?).with(:edit, presenter.id).and_return(false) }

    context "without files" do
      context "without uploads" do
        before { render "curation_concerns/base/items.html.erb", presenter: presenter }
        it { is_expected.not_to have_content("This Work has no files associated with it.") }
      end

      context "with uploads" do
        before do
          allow(presenter).to receive(:uploading?).and_return(true)
          render "curation_concerns/base/items.html.erb", presenter: presenter
        end
        it { is_expected.not_to have_content("Uploads are in progress.") }
      end

      context "with queued files" do
        before do
          allow(presenter).to receive(:queued_files).and_return([queued_file])
          render "curation_concerns/base/items.html.erb", presenter: presenter
        end
        it { is_expected.not_to have_content("Queued file") }
      end
    end
  end
end
