# frozen_string_literal: true

require 'rails_helper'

describe DownloadsController do
  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }
  let(:file)       { File.open(File.join(fixture_path, 'world.png')) }
  let(:my_file)    { create(:file_set, user: user, content: file) }
  let(:other_file) { create(:file_set, user: other_user, content: file) }
  let(:public_file) { create(:file_set, :public, user: user, content: file) }

  before do
    allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(false)
    allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
  end

  describe '#authorize_download!' do
    subject { controller.send(:authorize_download!) }

    context 'with a regular user' do
      before do
        allow_any_instance_of(User).to receive(:groups).and_return([])
      end

      context 'with my own file' do
        before { controller.params[:id] = my_file.id }

        it { is_expected.to eq(my_file.id) }
      end

      context 'with a file I do not have read access to' do
        before { controller.params[:id] = other_file.id }

        it 'denies access' do
          expect { subject }.to raise_error(CanCan::AccessDenied)
        end
      end

      context 'with my own work' do
        let(:my_work) { create :public_work_with_png, depositor: user.login }

        before { controller.params[:id] = my_work.id }

        it { is_expected.to eq(my_work.id) }
      end
    end

    context 'with an administrator' do
      before do
        allow_any_instance_of(User).to receive(:groups).and_return([ScholarSphere::Application.config.admin_group])
      end

      context 'with my own file' do
        before { controller.params[:id] = my_file.id }

        it { is_expected.to eq(my_file.id) }
      end

      context 'with a file I do not have read access to' do
        before { controller.params[:id] = other_file.id }

        it { is_expected.to eq(other_file.id) }
      end
    end

    context 'with no user' do
      before do
        allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(nil)
      end

      context 'with a public file' do
        before { controller.params[:id] = public_file.id }

        it { is_expected.to eq(public_file.id) }
      end

      context 'with a public file' do
        before { controller.params[:id] = other_file.id }

        it 'denies access' do
          expect { subject }.to raise_error(CanCan::AccessDenied)
        end
      end
    end
  end

  describe '#show' do
    subject(:path) { controller.send(:show) }

    let(:response) { instance_double ActionDispatch::Response, headers: {} }

    before do
      allow_any_instance_of(User).to receive(:groups).and_return([])
      allow(controller).to receive(:response).and_return(response)
    end

    context 'with a FileSet' do
      before do
        allow(response).to receive(:"status=")
        controller.params[:id] = my_file.id
      end

      it 'sends content' do
        # expect(controller).to receive(:send_content)
        expect(WorkZipService).not_to receive(:new)
        expect(controller).to receive(:send_file).with(/.*#{my_file.id}.*world.png/, type: 'image/png', disposition: 'inline')
        subject
      end
    end

    context 'with a non-public work' do
      let(:my_work) { create :registered_work, depositor: user.login }
      let(:response) { instance_double ActionDispatch::Response, headers: {} }

      before do
        controller.params[:id] = my_work.id
        allow(controller).to receive(:response).and_return(response)
      end

      it 'downloads a zip' do
        expect(WorkZipService).to receive(:new).with(my_work, anything, anything).and_call_original
        expect(controller).to receive(:send_file).with(
          Rails.root.join('tmp/derivatives',
                          my_work.id[0, 2],
                          my_work.id[2, 2],
                          my_work.id[4, 2],
                          my_work.id[6, 2],
                          'sample_title.zip').to_s,
                                        type: 'application/zip', disposition: 'inline'
                                      )
        subject
      end
    end

    context 'with a public work' do
      let(:my_work) { create :public_work, depositor: user.login }
      let(:zip_file) { ScholarSphere::Application.config.public_zipfile_directory.join("#{my_work.id}.zip") }

      before do
        FileUtils.touch(zip_file)
        controller.params[:id] = my_work.id
      end

      it 'downloads the public zip' do
        expect(WorkZipService).not_to receive(:new)
        expect(controller).to receive(:send_file)
          .with(zip_file.to_s, type: 'application/zip', disposition: 'inline')
        subject
      end
    end

    context 'with a non-public collection' do
      let(:my_collection) { create :registered_collection, depositor: user.login }
      let(:response) { instance_double ActionDispatch::Response, headers: {} }

      before do
        # I must save the work again because the factory just sends the representative id to solr
        #  This save sends the id to fedora
        my_collection.save
        controller.params[:id] = my_collection.id
        allow(controller).to receive(:response).and_return(response)
      end

      it 'downloads a zip' do
        expect(CollectionZipService).to receive(:new).with(my_collection, anything, anything).and_call_original
        expect(controller).to receive(:send_file)
        subject
      end
    end

    context 'with an unsupported class' do
      let(:unsupported_class) { BogusClass.create }
      let(:response) { instance_double ActionDispatch::Response, headers: {} }

      before do
        class BogusClass < ActiveFedora::Base
          def public?
            false
          end
        end

        controller.params[:id] = unsupported_class.id
        allow(controller).to receive(:response).and_return(response)
      end

      after do
        ActiveSupport::Dependencies.remove_constant('BogusClass')
      end

      it 'raises an error' do
        expect { subject }.to raise_error(DownloadsController::ZipServiceError, 'BogusClass cannot be downloaded as a zip file')
      end
    end

    context 'with an unknown file type' do
      let(:file) { File.open(File.join(fixture_path, 'special-mime-type.R')) }

      before do
        allow(response).to receive(:"status=")
        controller.params[:id] = my_file.id
      end

      it 'sends content' do
        expect(WorkZipService).not_to receive(:new)
        expect(controller).to receive(:send_file)
          .with(/.*#{my_file.id}.*special-mime-type.R/, type: 'application/octet-stream', disposition: 'inline')
        subject
      end
    end
  end
end
