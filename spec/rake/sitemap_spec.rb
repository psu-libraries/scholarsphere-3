# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Used to test the scholarsphere-fixtures rake task
#
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

  before(:all) do
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
        c.apply_depositor_metadata(u.user_key)
        c.save
        @collection_noids << c.noid
      end
    end
  end

  after(:all) do
    GenericFile.destroy_all
    Collection.destroy_all
    (1..15).each do |n|
      User.find_by(login: "user#{n}").destroy
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
      expect(Dir.glob(filename)).to have(1).entry
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
