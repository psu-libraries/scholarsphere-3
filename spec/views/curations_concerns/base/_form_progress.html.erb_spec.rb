# frozen_string_literal: true

require 'rails_helper'

describe 'curation_concerns/base/_form_progress.html.erb' do
  subject do
    view.simple_form_for(form) do |f|
      render 'curation_concerns/base/form_progress.html.erb', f: f
    end
    Capybara::Node::Simple.new(rendered)
  end

  let(:work)  { build(:work) }
  let(:proxy) { create(:first_proxy, id: 'abc123', display_name: 'Chuck Treece') }
  let(:form)  { CurationConcerns::GenericWorkForm.new(work, Ability.new(user)) }

  before { allow(controller).to receive(:current_user).and_return(user) }

  describe '#edit' do
    before { allow(controller).to receive(:action_name).and_return('edit') }

    context 'when the user is a proxy' do
      let(:user) { create(:user, :with_proxy, proxy_for: proxy) }

      it { is_expected.not_to have_selector('#generic_work_on_behalf_of') }
    end

    context 'when the user is not a proxy' do
      let(:user) { create(:user) }

      it { is_expected.not_to have_selector('#generic_work_on_behalf_of') }
    end
  end

  describe '#create' do
    before { allow(controller).to receive(:action_name).and_return('new') }

    context 'when the user is a proxy' do
      let(:user) { create(:user, :with_proxy, proxy_for: proxy) }

      it do
        expect(subject).to have_selector('#generic_work_on_behalf_of')
        expect(subject).to have_selector('option', text: 'Chuck Treece')
        expect(subject).not_to have_selector('option', text: 'abc123')
      end
    end

    context 'when the user is not a proxy' do
      let(:user) { create(:user) }

      it { is_expected.not_to have_selector('#generic_work_on_behalf_of') }
    end
  end
end
