# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::Resource, type: :model do
  describe 'table' do
    subject { described_class }

    its(:column_names) do
      is_expected.to include(
        'pid',
        'model',
        'client_status',
        'client_message',
        'exception',
        'error'
      )
    end
  end

  describe 'validations' do
    context 'when pid and model are missing' do
      subject { described_class.new }

      it { is_expected.not_to be_valid }
    end

    context 'when pid and model are provided' do
      subject { described_class.new(pid: '1234', model: 'GenericWork') }

      it { is_expected.to be_valid }
    end
  end

  describe '#migrated?' do
    context 'when the resource has been successfully published' do
      subject { described_class.new(client_status: 200) }

      it { is_expected.to be_migrated }
    end

    context 'when the resource has been migrated but not published' do
      subject { described_class.new(client_status: 201) }

      it { is_expected.to be_migrated }
    end

    context 'when an error is encountered' do
      subject { described_class.new(client_status: 422) }

      it { is_expected.not_to be_migrated }
    end
  end

  describe '#failed?' do
    context 'when the client returns an unsuccessful response' do
      subject { described_class.new(client_status: 422) }

      it { is_expected.to be_failed }
    end
  end

  describe '#blocked?' do
    context 'when a local error occurs' do
      subject { described_class.new(exception: 'ArgumentError') }

      it { is_expected.to be_blocked }
    end
  end

  describe '#message' do
    subject { described_class.new(pid: '1234', model: 'GenericWork', client_message: "{\"message\": \"success!\"}") }

    its(:message) { is_expected.to eq('message' => 'success!') }
    its(:message) { is_expected.to be_a(HashWithIndifferentAccess) }
  end

  describe '#migrate' do
    let(:success) { Faraday::Response.new(status: 200, body: '{"message": "success!"}') }

    context 'when the resource has not been migrated' do
      let(:resource) { described_class.new(pid: '1234', model: 'GenericWork') }

      it 'calls the export service' do
        expect(Scholarsphere::Migration::ExportService).to receive(:call).with('1234').and_return(success)
        resource.migrate
        expect(resource.client_status).to eq('200')
        expect(resource.client_message).to eq("{\"message\": \"success!\"}")
      end
    end

    context 'when the resource has already been migrated' do
      let(:resource) { described_class.new(pid: '1234', model: 'GenericWork', client_status: 200) }

      it 'does not call the export service' do
        expect(Scholarsphere::Migration::ExportService).not_to receive(:call).with('1234')
        expect { resource.migrate }.not_to(change { resource })
      end
    end

    context 'when forcing a re-migration' do
      let(:resource) { described_class.new(pid: '1234', model: 'GenericWork', client_status: 200) }

      it 'calls the export service' do
        expect(Scholarsphere::Migration::ExportService).to receive(:call).with('1234')
        expect { resource.migrate(force: true) }.to change(resource, :updated_at)
      end
    end

    context 'when the migration raises an error' do
      subject(:resource) { described_class.new(pid: '1234', model: 'GenericWork') }

      before do
        allow(Scholarsphere::Migration::ExportService)
          .to receive(:call)
          .with('1234')
          .and_raise(StandardError, 'oops, something went wrong!')
        resource.migrate
      end

      its(:exception) { is_expected.to eq('StandardError') }
      its(:error) { is_expected.to eq('oops, something went wrong!') }
    end
  end
end
