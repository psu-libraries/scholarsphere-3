# frozen_string_literal: true
require "rails_helper"

describe ResolrizeJob, :clean do
  let(:user) { create(:jill) }
  let!(:file_set) { create(:file_set, :with_png, id: "abc#{(Random.rand * 10_000).to_i}", depositor: user.login) }
  let(:job) { described_class.new }

  describe "#perform" do
    it "Updates the index for all parts of the records" do
      expect(ActiveFedora::Base).to receive(:find).with(file_set.access_control_id).and_return(file_set.access_control).ordered
      expect(file_set.access_control).to receive(:update_index)
      file_set.permissions.each do |perm|
        expect(ActiveFedora::Base).to receive(:find).with(perm.id).and_return(perm)
        expect(perm).to receive(:update_index).ordered
      end
      expect(ActiveFedora::Base).to receive(:find).twice.with(file_set.id).and_return(file_set).ordered
      expect(file_set).to receive(:update_index).twice
      job.perform_now
    end
  end
end
