# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'scholarsphere:files' do
  before do
    load_rake_environment ["#{Rails.root}/lib/tasks/scholarsphere/files.rake"]
  end

  describe ':create_derivatives' do
    let(:mock_service) { double }

    before do
      allow(mock_service).to receive(:create_derivatives)
      allow(mock_service).to receive(:errors).and_return(0)
    end

    context 'when no list is supplied' do
      it 'uses all FileSets' do
        expect(FileSetManagementService).to receive(:new).with([]).and_return(mock_service)
        run_task('scholarsphere:files:create_derivatives')
      end
    end

    context 'with a list of FileSet ids' do
      let(:argument) { '1 2 3' }

      it 'uses all FileSets' do
        expect(FileSetManagementService).to receive(:new).with(['1', '2', '3']).and_return(mock_service)
        run_task('scholarsphere:files:create_derivatives', argument)
      end
    end
  end

  describe ':characterize' do
    let(:mock_service) { double }

    before do
      allow(mock_service).to receive(:characterize)
      allow(mock_service).to receive(:errors).and_return(0)
    end

    context 'when no list is supplied' do
      it 'uses all FileSets' do
        expect(FileSetManagementService).to receive(:new).with([]).and_return(mock_service)
        run_task('scholarsphere:files:characterize')
      end
    end

    context 'with a list of FileSet ids' do
      let(:argument) { '1 2 3' }

      it 'uses all FileSets' do
        expect(FileSetManagementService).to receive(:new).with(['1', '2', '3']).and_return(mock_service)
        run_task('scholarsphere:files:characterize', argument)
      end
    end
  end

  describe ':zip' do
    context 'with works that exceed the threshold' do
      let(:id) { SecureRandom.uuid }
      let(:small_id) { SecureRandom.uuid }
      let(:psu_id) { SecureRandom.uuid }
      let(:private_id) { SecureRandom.uuid }

      before do
        index_document(build(:public_work).to_solr.merge!(bytes_lts: 600_000_000, id: id))
        index_document(build(:public_work).to_solr.merge!(bytes_lts: 100_000_000, id: small_id))
        index_document(build(:registered_work).to_solr.merge!(bytes_lts: 600_000_000, id: psu_id))
        index_document(build(:work).to_solr.merge!(bytes_lts: 600_000_000, id: private_id))
      end

      it 'submits jobs to create zip files for public and registered works only' do
        expect(ZipJob).to receive(:perform_later).with(id)
        expect(ZipJob).not_to receive(:perform_later).with(psu_id)
        expect(ZipJob).not_to receive(:perform_later).with(private_id)
        expect(ZipJob).not_to receive(:perform_later).with(small_id)
        run_task('scholarsphere:files:zip')
      end
    end
  end

  describe ':delete_zips' do
    let(:public_zip) { ScholarSphere::Application.config.public_zipfile_directory.join("#{SecureRandom.uuid}.zip") }
    let(:mock_zip_file) { instance_double(ZipFile) }

    before do
      Cleanup.directories
      FileUtils.touch(public_zip)
    end

    context 'when the zip file is stale' do
      before { allow(mock_zip_file).to receive(:stale?).and_return(true) }

      it 'removes the file' do
        expect(public_zip).to be_exist
        expect(ZipFile).to receive(:new).once.and_return(mock_zip_file)
        run_task('scholarsphere:files:delete_zips')
        expect(public_zip).not_to be_exist
      end
    end

    context 'when the zip file is not stale' do
      before { allow(mock_zip_file).to receive(:stale?).and_return(false) }

      it 'does not remove the file' do
        expect(public_zip).to be_exist
        expect(ZipFile).to receive(:new).once.and_return(mock_zip_file)
        run_task('scholarsphere:files:delete_zips')
        expect(public_zip).to be_exist
      end
    end
  end
end
