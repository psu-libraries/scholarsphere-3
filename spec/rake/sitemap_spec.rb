# frozen_string_literal: true
require "spec_helper"
require "rake"

describe "sitemap:generate" do
  def sitemap_path
    Gem.loaded_specs['sitemap'].full_gem_path
  end

  let(:user) { create(:user) }
  let!(:file) { create(:public_file, depositor: user.login) }
  let!(:private_file) { create(:private_file, depositor: user.login) }
  let!(:collection) { create(:collection, depositor: user.login) }
  before do
    # set up the rake environment
    load_rake_environment ["#{sitemap_path}/lib/tasks/sitemap.rake"]
  end

  describe 'sitemap generation', clean: true do
    it 'includes public generic files and users' do
      run_task 'sitemap:generate'
      filename = Rails.root.join(File.expand_path("public"), "sitemap.xml")
      expect(Dir.glob(filename).entries.size).to eq(1)
      f = File.open(filename)
      output = f.read
      expect(output).to include("/users/#{user.login}")
      expect(output).to include("/files/#{file.id}")
      expect(output).to include("/collections/#{collection.id}")
      expect(output).not_to include("/files/#{private_file.id}")
    end
  end
end
