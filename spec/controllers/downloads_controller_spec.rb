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
        allow_any_instance_of(User).to receive(:groups).and_return(['umg/up.dlt.scholarsphere-admin-viewers'])
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
    subject { controller.send(:show) }

    before do
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end

    context 'with a FileSet' do
      before { controller.params[:id] = my_file.id }
      it 'sends content' do
        expect(controller).to receive(:send_content)
        expect(WorkZipService).not_to receive(:new)
        subject
      end
    end

    context 'with a GenericWork' do
      let(:my_work) { create :public_work_with_png, depositor: user.login }
      let(:response) { instance_double ActionDispatch::Response, headers: {} }

      before do
        # I must save the work again because the factory just sends the representative id to solr
        #  This save sends the id to fedora
        my_work.save
        controller.params[:id] = my_work.id
        allow(controller).to receive(:response).and_return(response)
      end
      it 'downloads a zip' do
        expect(WorkZipService).to receive(:new).with(my_work, anything, anything).and_call_original
        expect(controller).to receive(:send_file)
        subject
      end
    end
  end
end
