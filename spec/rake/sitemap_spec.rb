require "spec_helper"
require "rake"

describe "sitemap:generate" do
  def sitemap_path
    Gem.loaded_specs['sitemap'].full_gem_path
  end

  let!(:user) {
    User.create(login: "user1", email: "user1@example.org")
  }
  let!(:file) {
    GenericFile.new do |f|
      f.apply_depositor_metadata(user.user_key)
      f.read_groups = ['public']
      f.save
    end
  }
  let!(:private_file) {
    GenericFile.new do |f|
      f.apply_depositor_metadata(user.user_key)
      f.save
    end
  }
  let!(:collection){
    Collection.new do |c|
      c.title = "Collection Title"
      c.apply_depositor_metadata(user.user_key)
      c.save
    end
  }
  before do
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
      expect(output).to include("/users/user1")
      expect(output).to include("/files/#{file.id}")
      expect(output).to include("/collections/#{collection.id}")
      expect(output).not_to include("/files/#{private_file.id}")
    end
  end
end
