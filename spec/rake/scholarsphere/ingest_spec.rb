# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'scholarsphere:files' do
  let(:path) { ScholarSphere::Application.config.network_ingest_directory.join('work1') }

  before do
    load_rake_environment ["#{Rails.root}/lib/tasks/scholarsphere/ingest.rake"]
    FileUtils.mkdir_p(path)
  end

  after { FileUtils.rm_rf(path) }

  it 'ingests files from a remote directory' do
    expect(NetworkIngestService).to receive(:call).with(path)
    run_task('scholarsphere:ingest')
  end
end
