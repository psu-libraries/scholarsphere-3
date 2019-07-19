# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Visting the home page:', type: :feature, js: true do
  subject { page }

  let!(:content_block) { create(:marketing_text) }

  context 'desktop view' do
    before do
      login_as current_user
      visit '/'
    end

    context 'and I do not belong to any groups' do
      let(:current_user) { create(:user) }

      it { is_expected.to have_content('Share. Manage. Preserve.') }
    end

    context 'and I belong to a couple of groups' do
      let(:current_user) { create(:user, :with_two_groups) }

      it do
        expect(subject).to have_content('Share. Manage. Preserve.')
        expect(subject).to have_content(current_user.display_name)
      end
    end

    context 'and I belong to a lot of groups' do
      let(:current_user) { create(:user, :with_many_groups) }

      it do
        expect(subject).to have_content('Share. Manage. Preserve.')
        expect(subject).to have_content(current_user.display_name)
      end
    end
  end

  context 'with a mobile device' do
    let(:current_user) { create(:user) }

    before do
      sign_in_with_named_js(:small_chrome, current_user, window_size: 'window-size=400,500')
      visit '/'
    end

    it do
      expect(page).not_to have_content(current_user.display_name)
    end
  end
end
