require 'spec_helper'

describe ScholarsphereBatchUpdateJob do
  let(:user) { FactoryGirl.find_or_create(:jill) }
  let(:batch) { Batch.create }

  let!(:file) do
    GenericFile.new(batch: batch) do |file|
      file.apply_depositor_metadata(user)
      file.save!
    end
  end

  let!(:file2) do
    GenericFile.new(batch: batch) do |file|
      file.apply_depositor_metadata(user)
      file.save!
    end
  end

  describe "#run" do
    let(:title) { { file.id => ['File One'], file2.id => ['File Two'] } }
    let(:metadata) do
      { read_groups_string: '', read_users_string: 'archivist1, archivist2',
        tag: [''] }.with_indifferent_access
    end

    let(:visibility) { "open" }

    let(:job) { described_class.new(user.user_key, batch.id, title, metadata, visibility) }

    describe "queuing jobs" do
      let(:s1) { double('one') }
      let(:s2) { double('two') }
      it "pushes two jobs per file" do
        expect_any_instance_of(User).to receive(:can?).with(:edit, file).and_return(true)
        expect_any_instance_of(User).to receive(:can?).with(:edit, file2).and_return(true)
        expect(ContentUpdateEventJob).to receive(:new).with(file.id, user.user_key).and_return(s1)
        expect(ShareNotifyJob).to receive(:new).with(file.id).and_return(s1)
        expect(Sufia.queue).to receive(:push).with(s1).twice
        expect(ContentUpdateEventJob).to receive(:new).with(file2.id, user.user_key).and_return(s2)
        expect(ShareNotifyJob).to receive(:new).with(file2.id).and_return(s2)
        expect(Sufia.queue).to receive(:push).with(s2).twice
        job.run
        expect(user.mailbox.inbox[0].messages[0].subject).to eq("Batch upload complete")
      end
    end
  end

end
