# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'sitemap:generate' do
  def sitemap_path
    Gem.loaded_specs['sitemap'].full_gem_path
  end

  let(:user) { create(:user) }
  let!(:file) { create(:public_work, depositor: user.login) }
  let!(:private_file) { create(:private_work, depositor: user.login) }
  let!(:collection) { create(:collection, depositor: user.login) }

  before do
    # set up the rake environment
    load_rake_environment ["#{sitemap_path}/lib/tasks/sitemap.rake"]
  end

  describe 'sitemap generation', clean: true do
    it 'includes public generic files and users' do
      run_task 'sitemap:generate'
      filename = Rails.root.join(File.expand_path('public'), 'sitemap.xml')
      expect(Dir.glob(filename).entries.size).to eq(1)
      f = File.open(filename)
      output = f.read
      expect(output).to include("https://scholarsphere.psu.edu/users/#{user.login}")
      expect(output).to include("https://scholarsphere.psu.edu/concern/generic_works/#{file.id}")
      expect(output).to include("https://scholarsphere.psu.edu/collections/#{collection.id}")
      expect(output).not_to include("/concern/generic_works/#{private_file.id}")
    end
  end
end
