require "spec_helper"
require "rake"

describe "sitemap:generate" do

  def loaded_files_excluding_current_rake_file
    $".reject { |file| file.include? "lib/tasks/sitemap" }
  end

  # saves original $stdout in variable
  # set $stdout as local instance of StringIO
  # yields to code execution
  # returns the local instance of StringIO
  # resets $stdout to original value
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out.string
  ensure
    $stdout = STDOUT
  end

  def sitemap_path
    Gem.loaded_specs['sitemap'].full_gem_path
  end

  def run_generate
    o = capture_stdout do
      @rake['sitemap:generate'].invoke
    end
  end

  before(:each) do
    (1..15).each do |n|
      u = User.create(login: "user#{n}", email: "user#{n}@example.org")
      @file_noids = []
      @collection_noids = []
      GenericFile.new.tap do |f|
        f.apply_depositor_metadata(u.user_key)
        f.read_groups = ['public']
        f.save
        @file_noids << f.noid
      end
      Collection.new.tap do |c|
        c.title = "Collection Title"
        c.apply_depositor_metadata(u.user_key)
        c.save
        @collection_noids << c.noid
      end
    end
  end

  # set up the rake environment
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require("lib/tasks/sitemap", [sitemap_path], loaded_files_excluding_current_rake_file)
    Rake::Task.define_task(:environment)
  end

  describe 'sitemap generation' do
    it 'should include public generic files and users' do
      run_generate
      filename = Rails.root.join(File.expand_path("public"), "sitemap.xml")
      expect(Dir.glob(filename).entries.size).to eq(1)
      f = File.open(filename)
      output = f.read
      (1..15).each do |n|
        expect(output).to include("/users/user#{n}")
      end
      @file_noids.each do |noid|
        expect(output).to include("/files/#{noid}")
      end
      @collection_noids.each do |noid|
        expect(output).to include("/collections/#{noid}")
      end
    end
  end
end
