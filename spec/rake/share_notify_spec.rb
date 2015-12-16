require "spec_helper"
require "rake"

describe "share" do

  before { load_rake_environment ["#{Rails.root}/lib/tasks/share_notify.rake"] }

  describe "files" do
    let(:file) { double("File", id: "1234") }
    let(:job)  { double("job") }
    before { allow_any_instance_of(ResourceFilteredList).to receive(:filter).and_return([file]) }
    it 'pushes all available files to SHARE Notify' do
      expect(ShareNotifyJob).to receive(:new).with(file.id).and_return(job)
      expect(Sufia.queue).to receive(:push).with(job).once
      run_task 'share:files'
    end
  end
end
