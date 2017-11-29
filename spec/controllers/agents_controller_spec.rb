# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe AgentsController do
  context 'a logged in user' do
    let(:user) { create(:user, display_name: 'First User') }
    let(:jamie) { create(:agent, given_name: 'Jamie', sur_name: 'Test', email: 'james@gmail.com', psu_id: 'jtt01', orcid_id: '1234') }
    let(:sally) { create(:agent, given_name: 'Sally', sur_name: 'James') }
    let(:sal) { create(:agent, given_name: 'Sal', sur_name: 'Anderson') }

    let(:ldap_attrs) { %i[uid givenname sn mail eduPersonPrimaryAffiliation displayname] }

    let(:jamie_l_franks_ldap_entry) do
      build(:ldap_entry,
            uid: 'qjf1',
            displayname: 'JAMIE L FRANKS',
            givenname: 'JAMIE L',
            sn: 'FRANKS',
            mail: 'qjf1@psu.edu')
    end
    let(:jamie_test_gmail_ldap_entry) do
      build(:ldap_entry,
            uid: 'jat1',
            displayname: 'JAMIE TEST',
            givenname: 'Jamie',
            sn: 'Test',
            mail: 'james@gmail.com')
    end
    let(:jamie_test_psu_ldap_entry) do
      build(:ldap_entry,
            uid: 'jat1',
            displayname: 'JAMIE TEST',
            givenname: 'Jamie',
            sn: 'Test',
            mail: 'jat1@psu.edu')
    end

    let(:janet_mouse_ldap_entry) do
      build(:ldap_entry,
            uid: 'jam',
            displayname: 'JANET A MOUSE',
            givenname: 'JANET A',
            sn: 'MOUSE',
            mail: 'jam@psu.edu')
    end

    let(:name_results) { [jamie_l_franks_ldap_entry,
                          jamie_test_gmail_ldap_entry,
                          jamie_test_psu_ldap_entry] }

    let(:mail_results) { [janet_mouse_ldap_entry, jamie_test_psu_ldap_entry] }

    let(:jamie_t_name_results) { [jamie_test_psu_ldap_entry] }

    let(:jamie_t_mail_results) { [] }

    describe 'GET name_search' do
      before do
        Alias.destroy_all && Agent.destroy_all
        create(:alias, display_name: 'Jamie Test', agent: jamie)
        create(:alias, display_name: 'Dr. James T. Test', agent: jamie)
        create(:alias, display_name: 'Sally James', agent: sally)
        create(:alias, display_name: 'Sal Anderson', agent: sal)
        allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
        allow_any_instance_of(User).to receive(:groups).and_return(['registered'])
      end
      it 'returns JSON search based on the first name & last name' do
        expect(LdapDisambiguate::LdapUser).to receive(:query_ldap_by_name).with('JAM', '*', ldap_attrs).and_return(name_results)
        expect(LdapDisambiguate::LdapUser).to receive(:query_ldap_by_mail).with('Jam@psu.edu', ldap_attrs).and_return(mail_results)
        get :name_query, q: 'Jam'
        results = JSON.parse(response.body)
        expect(results.count).to eq(6)
        expect(results.map { |x| x['display_name'] }.flatten).to contain_exactly('Dr. James T. Test', 'JAMIE L FRANKS', 'JAMIE TEST', 'JANET A MOUSE', 'Jamie Test', 'Sally James')
        expect(results.map { |x| x['given_name'] }.flatten).to contain_exactly('Jamie', 'Jamie', 'Sally')
        expect(results.map { |x| x['sur_name'] }.flatten).to contain_exactly('Test', 'Test', 'James')
        expect(results.map { |x| x['email'] }.flatten).to contain_exactly(nil, 'jam@psu.edu', 'jat1@psu.edu', 'james@gmail.com', 'qjf1@psu.edu', 'james@gmail.com')
        expect(results.map { |x| x['psu_id'] }.flatten).to contain_exactly('jtt01', 'jtt01', nil)
        expect(results.map { |x| x['orcid_id'] }.flatten).to contain_exactly(nil, nil, '1234', nil, nil, '1234')
      end
      it 'returns JSON results when queried with spaces' do
        expect(LdapDisambiguate::LdapUser).to receive(:query_ldap_by_name).and_return(jamie_t_name_results)
        expect(LdapDisambiguate::LdapUser).to receive(:query_ldap_by_mail).and_return(jamie_t_mail_results)
        get :name_query, q: 'Jamie T'
        results = JSON.parse(response.body)
        expect(results.count).to eq(2)
        expect(results.map { |x| x['display_name'] }.flatten).to contain_exactly('JAMIE TEST', 'Jamie Test')
        expect(results.map { |x| x['given_name'] }.flatten).to contain_exactly('Jamie')
        expect(results.map { |x| x['sur_name'] }.flatten).to contain_exactly('Test')
        expect(results.map { |x| x['email'] }.flatten).to contain_exactly('james@gmail.com', 'jat1@psu.edu')
        expect(results.map { |x| x['psu_id'] }.flatten).to contain_exactly('jtt01')
        expect(results.map { |x| x['orcid_id'] }.flatten).to contain_exactly(nil, '1234')
      end
    end
  end
end
