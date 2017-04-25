# frozen_string_literal: true
require 'rails_helper'

describe "curation_concerns/base/_form_files.html.erb" do
  let(:user)    { create(:user) }
  let(:work)    { create(:work, depositor: user.login) }
  let(:ability) { Ability.new(user) }
  let(:form)    { CurationConcerns::GenericWorkForm.new(work, ability) }

  let(:page) do
    view.simple_form_for form do |f|
      render 'curation_concerns/base/form_files.html.erb', f: f
    end
    Capybara::Node::Simple.new(rendered)
  end

  let(:all_label) { page.find('button.all')['aria-label'] }

  it "displays informative and accessible elements" do
    expect(page).to have_selector("h2", text: "Add Local Files")
    expect(page).to have_selector("h2", text: "Add Files from the Cloud")
    expect(page).to have_selector("h2", text: "Files Available for Upload")
    expect(page).to have_selector("caption", text: "Listing of files ready to be uploaded")
    expect(all_label).to eq("Upload all local files from the listing of files")
    expect(page).to have_selector("button.all", visible: false)
  end
end
