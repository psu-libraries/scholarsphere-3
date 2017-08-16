# frozen_string_literal: true

require 'rails_helper'

describe 'users/show.html.erb', type: :view do
  subject { rendered }

  let(:join_date) { 5.days.ago }
  let(:user)      { build(:user) }
  let(:ability)   { double(current_user: user) }
  let(:presenter) { Sufia::UserProfilePresenter.new(user, ability) }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:can?).and_return(true)
    assign(:user, user)
    assign(:presenter, presenter)
    render
  end

  describe "when the user doesn't have a title" do
    let(:user) { build(:user, title: nil, created_at: join_date) }

    it 'has the vitals' do
      expect(rendered).to match(/<span class="glyphicon glyphicon-time"><\/span> Joined on #{join_date.strftime("%b %d, %Y")}/)
      expect(rendered).not_to match(/<dt>Title<\/dt>/)
    end
  end

  describe 'when user has a title' do
    let(:user) { build(:user, created_at: join_date, title: 'Mrs') }

    it 'has the vitals' do
      expect(rendered).to match(/<span class="glyphicon glyphicon-time"><\/span> Joined on #{join_date.strftime("%b %d, %Y")}/)
      expect(rendered).to match(/<dt>Title<\/dt>/)
      expect(rendered).to match(/<dd>Mrs<\/dd>/)
    end
  end

  describe 'when user has a phone number' do
    let(:user) { build(:user, created_at: join_date, telephone: '+1 800 867 5309') }

    it { is_expected.to include('<a href="tel:+18008675309">+1 800 867 5309</a>') }
  end
end
