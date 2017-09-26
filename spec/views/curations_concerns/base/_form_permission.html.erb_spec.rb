# frozen_string_literal: true

require 'rails_helper'

describe 'curation_concerns/base/_form_permission.html.erb' do
  let(:work) { build(:work) }
  let(:form) { CurationConcerns::GenericWorkForm.new(work, Ability.new(nil)) }

  let(:page) {
    view.simple_form_for(form) do |f|
      render 'curation_concerns/base/form_permission.html.erb', f: f
    end
    Capybara::Node::Simple.new(rendered)
  }

  it 'omits the private visibility option' do
    expect(page).to have_no_checked_field('Private')
  end
end
