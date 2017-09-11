# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe PersonsController do
  context 'a logged in user' do
    before { Person.destroy_all }

    let(:user) { create(:user, display_name: 'First User') }
    let!(:jamie) { create(:person, first_name: 'Jamie', last_name: 'Test') }
    let!(:sally) { create(:person, first_name: 'Sally', last_name: 'James') }
    let!(:sal) { create(:person, first_name: 'Sal', last_name: 'Anderson') }

    describe 'GET name_search' do
      before do
        allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
        allow_any_instance_of(User).to receive(:groups).and_return(['registered'])
      end
      it 'returns JSON search based on the first name & last name' do
        get :name_query, q: 'Jam'
        results = JSON.parse(response.body)
        expect(results.count).to eq(2)
        expect(results.map { |x| x['first_name_tesim'] }.flatten).to contain_exactly('Jamie', 'Sally')
      end
    end
  end
end
