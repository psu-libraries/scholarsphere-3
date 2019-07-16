# frozen_string_literal: true

require 'rails_helper'

describe ZipJob do
  let(:job) { described_class }
  let(:mock_work_service) { instance_double(WorkZipService) }
  let(:mock_collection_service) { instance_double(CollectionZipService) }
  let(:path) { ScholarSphere::Application.config.public_zipfile_directory }
  let(:file) { "#{document.id}.zip" }

  context 'with a work' do
    let(:document) { create(:public_work) }

    it 'calls WorkZipService' do
      expect(WorkZipService).to receive(:new)
        .with(document, kind_of(Ability), path, "#{document.id}.zip")
        .and_return(mock_work_service)
      expect(mock_work_service).to receive(:call)
      job.perform_now(document.id)
    end
  end

  context 'with a collection' do
    let(:document) { create(:public_collection) }

    it 'calls CollectionZipService' do
      expect(CollectionZipService).to receive(:new)
        .with(document, kind_of(Ability), path, file)
        .and_return(mock_collection_service)
      expect(mock_collection_service).to receive(:call)
      job.perform_now(document.id)
    end
  end

  context 'when the zip file is not stale' do
    let(:document) { create(:public_work) }
    let(:mock_file) { instance_double(ZipFile) }

    before do
      allow(ZipFile).to receive(:new).and_return(mock_file)
      allow(mock_file).to receive(:stale?).and_return(false)
    end

    it 'does not call the WorkZipService' do
      expect(WorkZipService).not_to receive(:new)
      job.perform_now(document.id)
    end
  end

  context 'when specifying an unknown id' do
    specify do
      expect { job.perform_now('idontexist') }.to raise_error(ActiveFedora::ObjectNotFoundError)
    end
  end

  context 'with a non-exportable object' do
    let(:document) { create(:agent) }

    specify do
      expect { job.perform_now(document.id) }.to raise_error(ZipJob::Error)
    end
  end
end
