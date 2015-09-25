require "spec_helper"
require "rake"

describe "sitemap:generate" do
  def sitemap_path
    Gem.loaded_specs['sitemap'].full_gem_path
  end

  before do
    (1..15).each do |n|
      u = User.create(login: "user#{n}", email: "user#{n}@example.org")
      @file_ids = []
      @collection_ids = []
      GenericFile.new.tap do |f|
        f.apply_depositor_metadata(u.user_key)
        f.read_groups = ['public']
        f.save
        @file_ids << f.id
      end
      Collection.new.tap do |c|
        c.title = "Collection Title"
        c.apply_depositor_metadata(u.user_key)
        c.save
        @collection_ids << c.id
      end
    end

    # set up the rake environment
    load_rake_environment ["#{sitemap_path}/lib/tasks/sitemap.rake"]
  end

  describe 'sitemap generation' do
    it 'includes public generic files and users' do
      run_task 'sitemap:generate'
      filename = Rails.root.join(File.expand_path("public"), "sitemap.xml")
      expect(Dir.glob(filename).entries.size).to eq(1)
      f = File.open(filename)
      output = f.read
      (1..15).each do |n|
        expect(output).to include("/users/user#{n}")
      end
      @file_ids.each do |id|
        expect(output).to include("/files/#{id}")
      end
      @collection_ids.each do |id|
        expect(output).to include("/collections/#{id}")
      end
    end
  end
end
