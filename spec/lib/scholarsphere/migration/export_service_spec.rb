# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::ExportService, unless: travis? do
  let(:user) { create(:user) }
  let(:creator) { create(:creator) }

  context 'with a work' do
    let(:work) do
      create(
        :public_work_with_pdf, :with_complete_metadata,
        depositor: user.login,
        resource_type: ['Article']
      )
    end

    it 'exports a work to the Scholarsphere 4 ingest endpoint' do
      result = described_class.call(work.id)
      expect(result.status).to eq(200)
    end
  end

  context 'with a collection' do
    let(:collection) { create(:public_collection, :with_complete_metadata, depositor: user.login) }

    it 'exports the collection to the Scholarsphere 4 collections/create endpoint' do
      result = described_class.call(collection.id)
      expect(result.status).to eq(200)
    end
  end

  context 'with an unsupported class' do
    let(:agent) { create(:agent) }

    it 'raises an error' do
      expect {
        described_class.call(agent.id)
      }.to raise_error(ArgumentError, "can't export Agent")
    end
  end

  context "when the resource doesn't exist" do
    it 'raises an error' do
      expect {
        described_class.call('badid')
      }.to raise_error(ActiveFedora::ObjectNotFoundError)
    end
  end
end
