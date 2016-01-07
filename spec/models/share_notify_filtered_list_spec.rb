require 'spec_helper'

describe ShareNotifyFilteredList, type: :model do
  let(:shared_file) { GenericFile.new( title: ["shared"]) { |f| f.share_notify_id = 'some id' } }
  let(:unshared_file) { GenericFile.new(title: ["not shared"]) }

  subject {described_class.new([shared_file, unshared_file]).filter}

  describe "files that have not been sent to SHARE Notify" do
    it { is_expected.to contain_exactly(unshared_file) }
  end
end
