# frozen_string_literal: true
require 'rails_helper'
require 'rake'

describe "share" do
  before { load_rake_environment ["#{Rails.root}/lib/tasks/share_notify.rake"] }

  describe "files", clean: true do
    let(:work) { create(:public_work) }
    let(:job)  { double("job") }
    before { allow_any_instance_of(ResourceFilteredList).to receive(:filter).and_return([work]) }
    it 'pushes all available files to SHARE Notify' do
      expect(ShareNotifyJob).to receive(:perform_later).with(work)
      run_task 'share:files'
    end
  end
end
