# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe PersonsController do
  context 'a logged in user' do
    let(:user) { create(:user, display_name: 'First User') }
    let(:jamie) { create(:person, given_name: 'Jamie', sur_name: 'Test', email: 'james@gmail.com', psu_id: 'jtt01', orcid_id: '1234') }
    let(:sally) { create(:person, given_name: 'Sally', sur_name: 'James') }
    let(:sal) { create(:person, given_name: 'Sal', sur_name: 'Anderson') }

    describe 'GET name_search' do
      before do
        Alias.destroy_all && Person.destroy_all
        create(:alias, display_name: 'Jamie Test', person: jamie)
        create(:alias, display_name: 'Dr. James T. Test', person: jamie)
        create(:alias, display_name: 'Sally James', person: sally)
        create(:alias, display_name: 'Sal Anderson', person: sal)
        allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
        allow_any_instance_of(User).to receive(:groups).and_return(['registered'])
      end
      it 'returns JSON search based on the first name & last name' do
        get :name_query, q: 'Jam'
        results = JSON.parse(response.body)
        expect(results.count).to eq(3)
        expect(results.map { |x| x['display_name_tesim'] }.flatten).to contain_exactly('Jamie Test', 'Dr. James T. Test', 'Sally James')
        expect(results.map { |x| x['given_name_tesim'] }.flatten).to contain_exactly('Jamie', 'Jamie', 'Sally')
        expect(results.map { |x| x['sur_name_tesim'] }.flatten).to contain_exactly('Test', 'Test', 'James')
        expect(results.map { |x| x['email_ssim'] }.flatten).to contain_exactly('james@gmail.com', 'james@gmail.com', nil)
        expect(results.map { |x| x['psu_id_ssim'] }.flatten).to contain_exactly('jtt01', 'jtt01', nil)
        expect(results.map { |x| x['orcid_id_ssim'] }.flatten).to contain_exactly('1234', '1234', nil)
      end
    end
  end
end
