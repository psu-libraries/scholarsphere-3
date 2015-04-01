require "spec_helper"
require "rake"

describe "scholarsphere:fixtures" do

  def activefedora_path
    Gem.loaded_specs['active-fedora'].full_gem_path
  end

  def delete_fixture_files
    File.delete(Rails.root.join(File.expand_path("spec/fixtures/scholarsphere"), "scholarsphere_rspecTestFixture.txt"))
    File.delete(Rails.root.join(File.expand_path("spec/fixtures/scholarsphere"), "scholarsphere_rspecTestFixture.descMeta.txt"))
    File.delete(Rails.root.join(File.expand_path("spec/fixtures/scholarsphere"), "scholarsphere_rspecTestFixture.foxml.erb"))
    begin
      File.delete(Rails.root.join(File.expand_path("spec/fixtures/scholarsphere"), "scholarsphere_rspecTestFixture.foxml.xml"))
    rescue
      # do nothing; this just means the generate task was not called
    end
  end

  # set up the rake environment
  before do
    load_rake_environment ["lib/tasks/scholarsphere-fixtures.rake","#{activefedora_path}/lib/tasks/active_fedora.rake"]
  end

  after do
    delete_fixture_files
  end

  describe 'create, generate, load and delete' do
    it 'should load and then delete fixtures' do
      ENV["FIXTURE_ID"] = "rspecTestFixture"
      ENV["FIXTURE_TITLE"] = "rspec Test Fixture"
      ENV["FIXTURE_USER"] = "rspec"
      o = capture_stdout do
        @rake['scholarsphere:fixtures:create'].invoke
        @rake['scholarsphere:fixtures:generate'].invoke
        @rake['scholarsphere:fixtures:load'].invoke
        @rake['scholarsphere:fixtures:delete'].invoke
      end
      expect(Dir.glob(Rails.root.join(File.expand_path("spec/fixtures/scholarsphere"), "scholarsphere_rspecTestFixture.txt")).length).to eq(1)
      expect(Dir.glob(Rails.root.join(File.expand_path("spec/fixtures/scholarsphere"), "scholarsphere_rspecTestFixture.foxml.erb")).length).to eq(1)
      expect(Dir.glob(Rails.root.join(File.expand_path("spec/fixtures/scholarsphere"), "scholarsphere_rspecTestFixture.descMeta.txt")).length).to eq(1)
      expect(Dir.glob(Rails.root.join(File.expand_path("spec/fixtures/scholarsphere"), "scholarsphere_rspecTestFixture.foxml.xml")).length).to eq(1)
      expect(o).to include "Loaded 'scholarsphere:rspecTestFixture'"
      expect(o).to include "Deleted 'scholarsphere:rspecTestFixture'"
    end
  end
end
