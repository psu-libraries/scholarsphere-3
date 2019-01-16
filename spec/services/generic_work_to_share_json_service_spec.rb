# frozen_string_literal: true

require 'rails_helper'

describe GenericWorkToShareJSONService do
  let(:name_service) { double }
  let(:agent) { create(:agent, sur_name: 'Santy', given_name: 'Lorraine C') }
  let(:creator) { create(:alias, display_name: creator_name, agent: agent) }
  let(:creator_name) { 'Santy, Lorraine C' }

  before do
    allow_any_instance_of(GenericWork).to receive(:current_host).and_return('https://scholarsphere.psu.edu')
    allow(NameDisambiguationService).to receive(:new).with(creator_name).and_return(name_service)
  end

  context 'when checking the fixture file' do
    let(:file) { build(:file, id: 'x346f017s', title: ['Set9 ShamR 1.tif'], creators: [creator], date_modified: DateTime.parse('2015-07-30T20:15:08.528+00:00')) }
    let(:json) { JSON.parse(File.open(fixture_path + '/ss-share.json', 'rb').read) }

    it 'generates valid json' do
      pending('See issue #277')
      expect(name_service).to receive(:disambiguate).and_return([{ email: 'lcs13@psu.edu' }])
      expect(JSON.parse(described_class.new(file).json)).to eq(json)
    end
  end

  context 'when checking any file' do
    subject { JSON.parse(described_class.new(file).json) }

    let(:json_template) do
      "{
        \"jsonData\": {
          \"title\": \"#{title}\",
          \"contributors\": [{
              \"name\": \"#{creator_name}\",
              \"email\": \"#{creator_email}\"
            }],
          \"uris\": {
            \"canonicalUri\": \"https://scholarsphere.psu.edu/files/#{id}\",
            \"providerUris\": [ \"https://scholarsphere.psu.edu/files/#{id}\" ]
          },
          \"providerUpdatedDateTime\": \"#{date_uploaded}\"
        }
      }"
    end
    let(:json)    { JSON.parse(json_template) }
    let(:file)    { create(:file, id: id, title: [title], creators: [creator], date_modified: DateTime.parse(date_uploaded)) }
    let(:title)   { 'abc123' }
    let(:id) { 'zzzzz' }
    let(:date_uploaded) { '2015-07-30T20:15:08Z' }

    context 'when the creator exists in ldap' do
      let(:agent) { create(:agent, sur_name: 'Cole', given_name: 'Carolyn Ann') }
      let(:creator) { create(:alias, agent: agent) }
      let(:creator_name) { 'Cole, Carolyn Ann' }
      let(:creator_email) { 'cam156@psu.edu' }

      it 'formats the json' do
        pending('See issue #277')
        expect(name_service).to receive(:disambiguate).and_return([{ email: creator_email }])
        expect(subject).to eq(json)
      end
    end

    context 'when the creator does not exist in ldap' do
      let(:creator) { FactoryGirl.create(:agent, sur_name: 'Frog', given_name: 'Kermit The') }
      let(:creator_email) {}

      it 'formats the json' do
        pending('See issue #277')
        expect(name_service).to receive(:disambiguate).and_return([])
        expect(subject).to eq(json)
      end
    end

    context 'when deleting the file' do
      subject { JSON.parse(described_class.new(file, delete: true).json) }

      let(:agent) { create(:agent, sur_name: 'Guy', given_name: 'Bad') }
      let(:creator) { create(:alias, display_name: creator_name, agent: agent) }
      let(:creator_name) { 'Guy, Bad' }
      let(:creator_email) { 'badguy@trouble.com' }

      before { allow(name_service).to receive(:disambiguate).and_return([{ email: creator_email }]) }

      it 'adds a delete property' do
        expect(subject['jsonData']['otherProperties']).to eq([{ 'name' => 'status', 'properties' => { 'status' => ['deleted'] } }])
      end
    end
  end
end
