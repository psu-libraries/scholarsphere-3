# frozen_string_literal: true

require 'rails_helper'

describe 'dashboard/_index_partials/_heading_greetings.html.erb', type: :view do
  let(:ability) { double }

  before do
    allow(view).to receive(:current_user).and_return(stub_model(User, user_key: 'mjg'))
    allow(controller).to receive(:current_ability).and_return(ability)
  end

  context 'when a user is an administrator' do
    before do
      allow(ability).to receive(:can?).with(:admin_stats, User).and_return(true)
    end

    it 'creates a link to admin stats' do
      render
      page = Capybara::Node::Simple.new(rendered)
      expect(page).to have_content('Hello')
    end
  end

  context 'when a user is not an administrator' do
    before do
      allow(ability).to receive(:can?).with(:admin_stats, User).and_return(false)
    end

    it 'creates a link to admin stats' do
      render
      page = Capybara::Node::Simple.new(rendered)
      expect(page).to have_content('Hello')
    end
  end
end
