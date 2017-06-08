# frozen_string_literal: true
require 'rails_helper'

describe ProxyDepositRequest do
  context "when the work id is a FileSet" do
    let(:file_set) { create(:file_set) }
    let(:sender)   { create(:user) }
    let(:receiver) { create(:user) }
    let(:request)  { described_class.where(sending_user_id: sender.id).first }

    before do
      described_class.create(work_id: file_set.id,
                             sending_user_id: sender.id,
                             receiving_user_id: receiver.id)
    end

    it "logs an error" do
      expect { request.deleted_work? }.not_to raise_error(ActiveFedora::ActiveFedoraError)
    end
  end
end
