require "spec_helper"
require "rake"

describe "sitemap:generate" do

  def sitemap_path
    Gem.loaded_specs['sitemap'].full_gem_path
  end

  before do
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

    # set up the rake environment
    load_rake_environment ["#{sitemap_path}/lib/tasks/sitemap.rake"]
  end

  describe 'sitemap generation' do
    it 'should include public generic files and users' do
      run_task 'sitemap:generate'
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
