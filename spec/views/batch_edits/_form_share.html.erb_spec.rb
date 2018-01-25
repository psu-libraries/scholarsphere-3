# frozen_string_literal: true

require 'rails_helper'

describe 'batch_edits/_form_share.html.erb' do
  let(:user) { create(:user) }
  let(:jill) { create(:jill) }
  let(:ability) { Ability.new(user) }
  let(:work1) { create(:work, :with_complete_metadata, title: ['First batch work'], edit_users: [jill.login]) }
  let(:work2) { create(:work, :with_complete_metadata, title: ['Second batch work'], edit_users: [jill.login]) }
  let(:batch) { [work1.id, work2.id] }
  let(:model) { BatchEditItem.new(batch: batch) }
  let(:form) { BatchEditForm.new(model, ability, batch) }

  let(:page) do
    view.simple_form_for(form, url: batch_edits_path) do |f|
      render 'batch_edits/form_share.html.erb', f: f
    end
    Capybara::Node::Simple.new(rendered)
  end

  before do
    allow(view).to receive(:current_user).and_return(user)
  end

  it 'renders additional permission information' do
    expect(page).to have_selector('#batch_edit_item_permissions_attributes_0_type', visible: false)
    expect(page).to have_selector('#batch_edit_item_permissions_attributes_0_name', visible: false)
    expect(page).to have_selector('#batch_edit_item_permissions_attributes_1_type', visible: false)
    expect(page).to have_selector('#batch_edit_item_permissions_attributes_1_name', visible: false)
  end
end
