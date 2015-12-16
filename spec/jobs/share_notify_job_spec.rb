require 'spec_helper'

describe ShareNotifyJob do
  let(:user) { FactoryGirl.find_or_create(:jill) }
  let(:job)  { described_class.new(file.id) }

  context "with a shareable file" do
    before { allow_any_instance_of(GenericFile).to receive(:share_notified?).and_return(false) }

    describe "a successful outcome" do
      let(:file) do
        GenericFile.create.tap do |f|
          f.title = ["The Difficulties of Being Green"]
          f.resource_type = ["Dissertation"]
          f.visibility = "open"
          f.date_modified = DateTime.now
          f.apply_depositor_metadata(user)
          f.save
        end
      end
      
      before { allow_any_instance_of(ShareNotify::SearchResponse).to receive(:status).and_return(200) }

      it "sends a notification" do
        expect(Sufia.queue).to receive(:push).with(an_instance_of(ShareNotifyEventJob))
        job.run
      end

      context "that has already been sent to SHARE Notify" do
        before { allow_any_instance_of(GenericFile).to receive(:share_notified?).and_return(true) }
        subject { job.run }
        it { is_expected.to be_nil }
      end
    end

    describe "an unsuccessful outcome" do
      let(:file) do
        GenericFile.create.tap do |f|
          f.title = ["Bad File"]
          f.resource_type = ["Dissertation"]
          f.visibility = "open"
          f.apply_depositor_metadata(user)
          f.save
        end
      end
      before { allow_any_instance_of(ShareNotify::SearchResponse).to receive(:status).and_return(400) }
      it "logs the error" do
        expect(Rails.logger).to receive(:warn).once
        job.run
      end
    end
  end

  context "with a file that cannot be shared" do
    let(:file) do
      GenericFile.create.tap do |f|
        f.title = ["Public Dissertation"]
        f.resource_type = ["Dissertation"]
        f.apply_depositor_metadata("user")
        f.save
      end
    end
    subject { job.run }
    it { is_expected.to be_nil }
  end

end
