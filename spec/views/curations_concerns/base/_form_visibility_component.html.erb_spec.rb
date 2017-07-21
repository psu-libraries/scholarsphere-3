# frozen_string_literal: true

require "rails_helper"

describe "curation_concerns/base/_form_visibility_component.html.erb" do
  let(:work) { build(:work) }
  let(:form) { CurationConcerns::GenericWorkForm.new(work, Ability.new(nil)) }

  let(:page) do
    view.simple_form_for(form) do |f|
      render "curation_concerns/base/form_visibility_component.html.erb", f: f
    end
    Capybara::Node::Simple.new(rendered)
  end

  it "omits the private visibility option" do
    expect(page).to have_no_checked_field("Private")
  end

  it "has an embargo date" do
    expect(page.find("#generic_work_embargo_release_date").value).to eq((Date.tomorrow + 2.years).to_s)
  end
end
