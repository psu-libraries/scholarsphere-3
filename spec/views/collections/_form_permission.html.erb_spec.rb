# frozen_string_literal: true

require 'rails_helper'

describe 'collections/_form_permission.html.erb' do
  let(:collection) { build(:collection) }
  let(:form) { CollectionForm.new(collection, Ability.new(nil), double) }

  let(:page) do
    view.simple_form_for form do |f|
      render 'collections/form_permission.html.erb', f: f
    end
    Capybara::Node::Simple.new(rendered)
  end

  before { assign(:collection, collection) }

  it 'omits the private visibility option' do
    expect(page).to have_no_checked_field('Private')
  end
end
