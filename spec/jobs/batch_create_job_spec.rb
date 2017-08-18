# frozen_string_literal: true

require 'rails_helper'

describe BatchCreateJob do
  let(:user) { create(:user) }
  let(:log)  { create(:batch_create_operation, user: user) }

  describe '#perform' do
    context 'with local files' do
      let(:uploaded_files) { ['1', '2'] }
      let(:titles)         { { '1' => 'File One', '2' => 'File Two' } }
      let(:resource_types) { { '1' => 'Article', '2' => 'Image' } }
      let(:attributes)     { { keyword: [], 'remote_files' => [], 'uploaded_files' => uploaded_files } }
      let(:uploaded_file1) { { keyword: [], uploaded_files: ['1'], title: ['File One'], resource_type: ['Article'] } }
      let(:uploaded_file2) { { keyword: [], uploaded_files: ['2'], title: ['File Two'], resource_type: ['Image'] } }

      it 'creates works' do
        expect(CreateWorkJob).to receive(:perform_later).with(user, 'GenericWork', uploaded_file1, CurationConcerns::Operation)
        expect(CreateWorkJob).to receive(:perform_later).with(user, 'GenericWork', uploaded_file2, CurationConcerns::Operation)
        described_class.perform_now(user, titles, resource_types, attributes, log)
      end
    end

    context 'with remote files' do
      let(:remote_file)    { { 'url' => 'file:///remote.txt', 'file_name' => 'remote.txt', 'file_size' => '100' } }
      let(:titles)         { { 'file:///remote.txt' => 'remote.txt' } }
      let(:resource_types) { { 'file:///remote.txt' => 'Article' } }
      let(:attributes)     { { keyword: [], 'remote_files' => [remote_file], 'uploaded_files' => [] } }

      let(:expected_remote_file) { { keyword: [], remote_files: [remote_file], title: ['remote.txt'], resource_type: ['Article'] } }

      it 'creates works' do
        expect(CreateWorkJob).to receive(:perform_later).with(user, 'GenericWork', expected_remote_file, CurationConcerns::Operation)
        described_class.perform_now(user, titles, resource_types, attributes, log)
      end
    end

    context 'with both remote and local files' do
      let(:uploaded_files) { ['1'] }
      let(:remote_file)    { { 'url' => 'file:///remote.txt', 'file_name' => 'remote.txt', 'file_size' => '100' } }
      let(:titles)         { { '1' => 'File One', 'file:///remote.txt' => 'remote.txt' } }
      let(:resource_types) { { '1' => 'Article', 'file:///remote.txt' => 'Article' } }
      let(:attributes)     { { keyword: [], 'remote_files' => [remote_file], 'uploaded_files' => uploaded_files } }

      let(:uploaded_file1)       { { keyword: [], uploaded_files: ['1'], title: ['File One'], resource_type: ['Article'] } }
      let(:expected_remote_file) { { keyword: [], remote_files: [remote_file], title: ['remote.txt'], resource_type: ['Article'] } }

      it 'creates works' do
        expect(CreateWorkJob).to receive(:perform_later).with(user, 'GenericWork', uploaded_file1, CurationConcerns::Operation)
        expect(CreateWorkJob).to receive(:perform_later).with(user, 'GenericWork', expected_remote_file, CurationConcerns::Operation)
        described_class.perform_now(user, titles, resource_types, attributes, log)
      end
    end
  end
end
