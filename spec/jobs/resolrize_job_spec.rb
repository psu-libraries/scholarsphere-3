# frozen_string_literal: true

require 'rails_helper'

describe ResolrizeJob, :clean do
  let(:user) { create(:jill) }
  let!(:file_set) { create(:file_set, :with_png, id: "abc#{(Random.rand * 10_000).to_i}", depositor: user.login) }
  let(:job) { described_class.new }
  let(:connection) { Faraday.new(ActiveFedora.fedora.host + ActiveFedora.fedora.base_path, request: { timeout: 800 }) }

  describe '#perform' do
    before do
      allow(ActiveFedora::Base).to receive(:find).and_call_original
    end

    it 'Updates the index for all parts of the records' do
      expect(Faraday).to receive(:new).and_return(connection)
      expect(connection).to receive(:basic_auth).with('fedoraAdmin', 'fedoraAdmin').and_call_original
      expect(ActiveFedora::Base).to receive(:find).with(file_set.access_control_id).and_return(file_set.access_control).ordered
      expect(file_set.access_control).to receive(:update_index)
      expect(ActiveFedora::Base).to receive(:find).with(file_set.id).and_return(file_set).ordered
      file_set.permissions.each do |perm|
        expect(ActiveFedora::Base).to receive(:find).with(perm.id).and_return(perm).ordered
        expect(perm).to receive(:update_index)
      end
      expect(file_set).to receive(:update_index)
      expect(ActiveFedora::Base).to receive(:find).with(file_set.id).and_return(file_set).ordered
      expect(file_set).to receive(:update_index)
      job.perform_now
    end
  end
end
