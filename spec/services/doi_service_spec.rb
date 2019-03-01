# frozen_string_literal: true

require 'rails_helper'

describe DOIService do
  subject(:run_service) { service.run(object) }

  let(:service) { described_class.new('testhandle') }
  let(:first_creator) { create(:alias, display_name: 'First Creator', agent: Agent.new(given_name: 'First', sur_name: 'Creator')) }
  let(:second_creator) { create(:alias, display_name: 'Second Creator', agent: Agent.new(given_name: 'Second', sur_name: 'Creator')) }

  let(:upload_date) { Time.now }
  let(:object) do
    create(:work,
      title: ['DOI Title'],
      creators: [first_creator, second_creator],
      identifier: identifier,
      resource_type: ['Article'],
      date_uploaded: upload_date)
  end

  context 'existing doi' do
    let(:identifier) { ['doi:10.5072/FK2VT1Q90B'] }

    it { is_expected.to eq(identifier.first) }
  end

  context 'no existing doi' do
    let(:identifier) { ['abc:10.5072/FK2VT1Q90B'] }
    let(:doi) { 'doi:10.5072/FK2VT1Q90B' }
    let(:response_body) { 'success: doi:10.5072/FK2VT1Q90B | ark:/b5072/fk2vt1q90b' }
    let(:client) { instance_double(Ezid::Client) }
    let(:response) { instance_double(Ezid::MintIdentifierResponse, id: doi) }
    let(:metadata) { { 'datacite.creator' => 'Creator, First; Creator, Second',
                       'datacite.title' => 'DOI Title',
                       'datacite.publisher' => 'ScholarSphere',
                       'datacite.publicationyear' => upload_date.year.to_s,
                       'datacite.resourcetype' => 'Text',
                       target: object.url } }

    before do
      allow(Ezid::Client).to receive(:new).and_return(client)
    end

    it 'mints a new id' do
      expect(client).to receive(:mint_identifier).with('testhandle', metadata).and_return(response)
      minted_id = service.run(object)
      expect(object.reload.identifier).to eq([identifier.first, doi])
      expect(minted_id).to eq(doi)
    end

    context 'the client errors' do
      it 'logs an error' do
        expect(client).to receive(:mint_identifier).with('testhandle', metadata).and_raise(Ezid::Error, 'bad error')
        expect(DOIFailureJob).to receive(:perform_later).with(object, anything)
        minted_id = service.run(object)
        expect(minted_id).to be_blank
      end
    end
  end

  context 'with a collection' do
    let(:object) { create(:collection, title: ['DOI Collection'], date_uploaded: upload_date) }
    let(:doi) { 'doi:10.5072/FK2VT1Q90B' }
    let(:response_body) { 'success: doi:10.5072/FK2VT1Q90B | ark:/b5072/fk2vt1q90b' }
    let(:client) { instance_double(Ezid::Client) }
    let(:response) { instance_double(Ezid::MintIdentifierResponse, id: doi) }
    let(:metadata) { { 'datacite.creator' => 'Creator, Creator C.',
                       'datacite.title' => 'DOI Collection',
                       'datacite.publisher' => 'ScholarSphere',
                       'datacite.publicationyear' => upload_date.year.to_s,
                       'datacite.resourcetype' => 'Collection',
                       target: object.url } }

    before do
      allow(Ezid::Client).to receive(:new).and_return(client)
    end

    it 'creates an id without a resource type' do
      expect(client).to receive(:mint_identifier).with('testhandle', metadata).and_return(response)
      minted_id = service.run(object)
      expect(minted_id).to eq(doi)
    end

    context 'the client errors' do
      it 'logs an error' do
        expect(client).to receive(:mint_identifier).with('testhandle', metadata).and_raise(Ezid::Error, 'bad error')
        expect(DOIFailureJob).not_to receive(:perform_later)
        minted_id = service.run(object)
        expect(minted_id).to be_blank
      end
    end
  end

  context 'all the resource types' do
    let(:doi) { 'doi:10.5072/FK2VT1Q90B' }
    let(:response_body) { 'success: doi:10.5072/FK2VT1Q90B | ark:/b5072/fk2vt1q90b' }
    let(:client) { instance_double(Ezid::Client) }
    let(:response) { instance_double(Ezid::MintIdentifierResponse, id: doi) }
    let(:work) do
      create(:work, title: ['DOI Title'],
                    creators: [first_creator, second_creator],
                    resource_type: [], date_uploaded: upload_date)
    end

    it 'maps the resource type correctly' do
      allow(Ezid::Client).to receive(:new).and_return(client)
      check_resource_type(work: work, client: client,
                          resource_types: ['Audio'], datacite_type: 'Sound')
      check_resource_type(work: work, client: client,
                          resource_types: ['Dataset'], datacite_type: 'Dataset')
      check_resource_type(work: work, client: client,
                          resource_types: ['Image', 'Map or Cartographic Material'],
                          datacite_type: 'Image')
      check_resource_type(work: work, client: client,
                          resource_types: ['Poster', 'Presentation', 'Video'],
                          datacite_type: 'Audiovisual')
      check_resource_type(work: work, client: client,
                          resource_types: ['Project', 'Other'],
                          datacite_type: 'Other')
      check_resource_type(work: work, client: client,
                          resource_types: [
                            'Software or Program Code'
                          ], datacite_type: 'Software')
      check_resource_type(work: work, client: client,
                          resource_types: ['Article', 'Book', 'Capstone Project',
                                           'Conference Proceeding', 'Dissertation',
                                           'Journal', 'Masters Thesis', 'Part of Book',
                                           'Report', 'Research Paper'],
                          datacite_type: 'Text')
    end
  end
end

def check_resource_type(work:, client:, resource_types:, datacite_type:)
  resource_types.each do |resource_type|
    work.resource_type = [resource_type]
    work.identifier = []

    metadata = { 'datacite.creator' => 'Creator, First; Creator, Second',
                 'datacite.title' => 'DOI Title',
                 'datacite.publisher' => 'ScholarSphere',
                 'datacite.publicationyear' => work.date_uploaded.year.to_s,
                 'datacite.resourcetype' => datacite_type,
                 target: work.url }
    expect(client).to receive(:mint_identifier).with('testhandle', metadata).and_return(response)
    service.run(work)
  end
end
