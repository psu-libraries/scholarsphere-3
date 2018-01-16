# frozen_string_literal: true

require 'rails_helper'

describe DOIService do
  subject(:run_service) { service.run(work) }

  let(:service) { described_class.new('testhandle', 'testuser', 'testpassword') }
  let(:work) { create(:work, identifier: identifier) }

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
    let(:metadata) { { 'datacite.creator' => work.creator,
                       'datacite.title' => work.title,
                       'datacite.publisher' => 'ScholarSphere',
                       'datacite.publicationyear' => '2018',
                       target: work.url } }

    before do
      allow(Ezid::Client).to receive(:new).and_return(client)
    end

    it 'mints a new id' do
      expect(client).to receive(:mint_identifier).with('testhandle', metadata).and_return(response)
      minted_id = service.run(work)
      expect(work.reload.identifier).to eq([identifier.first, doi])
      expect(minted_id).to eq(doi)
    end
  end
end
