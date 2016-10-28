# frozen_string_literal: true
require 'rails_helper'

describe "curation_concerns/base/_member.html.erb", verify_partial_doubles: false do
  let(:user)     { create(:user) }
  let(:solr_doc) { SolrDocument.new(build(:file_set, id: "1234").to_solr) }
  let(:ability)  { Ability.new(user) }
  let(:member)   { FileSetPresenter.new(solr_doc, ability) }

  subject { Capybara::Node::Simple.new(rendered) }

  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(view).to receive(:render_thumbnail_tag).with(member).and_return("thumbnail tag")
    allow(view).to receive(:contextual_path).and_return("contextual_path")
    allow(ability).to receive(:can?).with(:read, member.id).and_return(true)
  end

  context "when the user can only read" do
    before do
      allow(ability).to receive(:can?).with(:edit, member.id).and_return(false)
      render("curation_concerns/base/member.html.erb", member: member)
    end
    it { is_expected.to have_selector('a.btn', text: "Download") }
  end

  context "when the user can edit" do
    before do
      allow(ability).to receive(:can?).with(:edit, member.id).and_return(true)
      allow(ability).to receive(:can?).with(:destroy, member.id).and_return(true)
      render("curation_concerns/base/member.html.erb", member: member)
    end
    it { is_expected.to have_selector("button#dropdownMenu_1234") }
  end
end
