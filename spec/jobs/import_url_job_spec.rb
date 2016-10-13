# frozen_string_literal: true
require 'spec_helper'

describe ImportUrlJob do
  let(:user) { create(:jill) }

  let(:expanded_file_path) { File.expand_path('../../fixtures/world.png', __FILE__) }
  let(:file_path) { '/world.png' }
  let(:file_hash) { '/673467823498723948237462429793840923582' }
  let(:import_url) { "http://example.org#{file_hash}" }
  let(:generic_file) { create(:file, depositor: user.login, import_url: import_url,
                                     label: file_path)}

  let(:mock_response) do
    instance_double('HttpResponse').tap do |http_res|
      allow(http_res).to receive(:start).and_yield
      allow(http_res).to receive(:content_type).and_return('image/png')
      allow(http_res).to receive(:read_body).and_yield(File.open(expanded_file_path).read)
    end
  end

  subject(:job) { described_class.new(generic_file.id) }

  it "has no content at the outset" do
    expect(generic_file.content.size).to be_nil
  end

  context "after running the job" do
    let(:file) { generic_file.reload }

    before do
      s1 = instance_double('ContentDepositEventJob')
      allow(ContentDepositEventJob).to receive(:new).with(generic_file.id, 'jilluser').and_return(s1).once
      expect(Sufia.queue).to receive(:push).with(s1).once

      s2 = instance_double('CharacterizeJob')
      allow(CharacterizeJob).to receive(:new).with(generic_file.id).and_return(s2)
      expect(Sufia.queue).to receive(:push).with(s2).once

      expect(Sufia::GenericFile::Actor).to receive(:virus_check).and_return(false)
    end

    it "creates a content datastream" do
      expect_any_instance_of(Net::HTTP).to receive(:request_get).with(file_hash).and_yield(mock_response)
      job.run
      expect(file.content.size).to eq 4218
      expect(file.content.mime_type).to eq('image/png')
      expect(user.mailbox.inbox.first.last_message.body).to eq("The file (#{file_path}) was successfully imported.")
    end
    context "file uri" do
      let(:import_url) { "file://#{expanded_file_path}" }
      it "creates content from a file" do
        job.run
        expect(file.content.size).to eq 4218
        expect(file.content.mime_type).to eq('image/png')
        expect(user.mailbox.inbox.first.last_message.body).to eq("The file (#{file_path}) was successfully imported.")
      end
    end
  end

  context "when the file has a virus" do
    before do
      allow(ContentDepositEventJob).to receive(:new).with(generic_file.id, 'jilluser').never

      allow(CharacterizeJob).to receive(:new).with(generic_file.id).never
    end
    it "aborts if virus check fails" do
      allow(Sufia::GenericFile::Actor).to receive(:virus_check).and_raise(Sufia::VirusFoundError.new('A virus was found'))
      job.run
      expect(user.mailbox.inbox.first.subject).to eq("File Import Error")
    end
  end

  context "when a batch update job is running too" do
    let(:title) { { generic_file.id => ['File One'] } }
    let(:metadata) { {} }
    let(:visibility) { nil }

    let(:batch) { Batch.create }
    let(:batch_job) { BatchUpdateJob.new(user.user_key, batch.id, title, metadata, visibility) }

    before do
      generic_file.batch = batch
      generic_file.save
      allow_any_instance_of(Ability).to receive(:can?).and_return(true)
      expect_any_instance_of(Net::HTTP).to receive(:request_get).with(file_hash).and_yield(mock_response)
    end

    it "does not kill all the metadata set by other jobs" do
      # load the object before running the batch job
      gf = job.object

      # runthe batch job to set the title
      batch_job.run

      # run the import job
      job.run

      # import job should not override the title set by the batch job
      file = GenericFile.find(gf.id)
      expect(file.title).to eq(['File One'])
    end
  end
end
