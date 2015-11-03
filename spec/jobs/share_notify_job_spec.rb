require 'spec_helper'
require 'support/vcr'

describe ShareNotifyJob do

  before(:all) { WebMock.enable! }

  before { allow(ShareNotify).to receive(:config) { { "token" => "SECRET_TOKEN" } } }

  after(:all) { WebMock.disable! }

  context "with a shareable file" do
    
    let(:user) { FactoryGirl.find_or_create(:jill) }

    describe "a shareable file" do
      let(:public_dissertation) do
        GenericFile.create.tap do |f|
          f.title = ["The Difficulties of Being Green"]
          f.resource_type = ["Dissertation"]
          f.visibility = "open"
          f.date_modified = DateTime.now
          f.apply_depositor_metadata(user)
          f.save
        end
      end
      let(:contributors) { [ { name: "Frog, Kermit T.", email: "kermit@muppets.org" } ] }
      let(:job) { described_class.new(public_dissertation.id) }
      
      before do
        allow_any_instance_of(GenericFileToShareJSONService).to receive(:contributors).and_return(contributors)
        VCR.use_cassette('share_notify_job_success', record: :none) { job.run }
      end

      subject { public_dissertation.reload }
      it { is_expected.to be_share_notified }

      context "that has already been sent to SHARE Notify" do
        before { allow(public_dissertation).to receive(:share_notified?).and_return(true) }
        subject { job.run }
        it { is_expected.to be_nil }
      end
    end

    describe "an unsuccessful outcome" do
      let(:bad_file) do
        GenericFile.create.tap do |f|
          f.title = ["Bad File"]
          f.resource_type = ["Dissertation"]
          f.visibility = "open"
          f.apply_depositor_metadata(user)
          f.save
        end
      end
      let(:job) { described_class.new(bad_file.id) }

      it "logs the error" do
        VCR.use_cassette('share_notify_job_failure', record: :none) do
          expect(Rails.logger).to receive(:warn).once
          job.run
        end
      end
    end
  end

  context "with a file that cannot be shared" do
    let(:private_dissertation) do
      GenericFile.create.tap do |f|
        f.title = ["Public Dissertation"]
        f.resource_type = ["Dissertation"]
        f.apply_depositor_metadata("user")
        f.save
      end
    end
    let(:job) { described_class.new(private_dissertation.id) }
    subject { job.run }
    it { is_expected.to be_nil }
  end

end
