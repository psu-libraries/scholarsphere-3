# frozen_string_literal: true
require 'spec_helper'

describe ResolrizeJob, :clean do
  let(:user)   { create(:jill) }
  let!(:file)  { create(:file, :with_png, depositor: user.login) }
  let(:job) { described_class.new }

  describe "#run" do
    it "Updates the index for all parts of the records" do
      file.permissions.each do |perm|
        expect(ActiveFedora::Base).to receive(:find).with(perm.id).and_return(perm)
        expect(perm).to receive(:update_index).ordered
      end
      expect(ActiveFedora::Base).to receive(:find).with(file.id).and_return(file).ordered
      expect(file).to receive(:update_index)
      job.run
    end
  end
end
