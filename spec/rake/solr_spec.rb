require "spec_helper"
require "rake"

describe "scholarsphere:solr" do

  before do
    load_rake_environment ["#{Rails.root}/lib/tasks/scholarsphere-solr.rake"]
  end

  context "with incorrect input" do
    describe "index" do
      it "raises an error" do
        expect { run_task 'scholarsphere:solr:index' }.to raise_error(RuntimeError)
      end
    end
  end

  context "with a sample file" do
    before do
      GenericFile.create.tap do |f|
        f.title = ["Rake test"]
        f.apply_depositor_metadata "user"
        f.save
      end
    end
    
    describe "index" do
      let(:id) { GenericFile.all.first.id }
      subject { capture_stdout { Rake::Task["scholarsphere:solr:index"].invoke(id) } }
      it { is_expected.to be_empty }
    end

    describe "compare" do
      subject { capture_stdout { Rake::Task["scholarsphere:solr:compare"].invoke } }
      it { is_expected.to start_with("Things appear to be OK") }
      context "when solr and fedora are out of sync" do
        let!(:count) { ActiveFedora::Base.count }
        before { ActiveFedora::Cleaner.cleanout_solr }
        it "raises an error" do
          expect { run_task "scholarsphere:solr:compare" }.to raise_error(RuntimeError, "Fedora's #{count} objects exceeds Solr's 0")
        end
      end
    end
  end

end
