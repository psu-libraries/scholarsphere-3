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

  # set up the rake environment
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require("lib/tasks/sitemap", [sitemap_path], loaded_files_excluding_current_rake_file)
    Rake::Task.define_task(:environment)
  end

  after(:each) do
  end

  describe 'sitemap generation' do
    it 'should include public generic files and users' do
      gf = GenericFile.new
      gf.apply_depositor_metadata "architect"
      gf.read_groups = ['public']
      gf.save
      @user = FactoryGirl.find_or_create(:user)
      run_generate
      filename= Rails.root.join(File.expand_path("public"), "sitemap.xml")
      Dir.glob(filename).length.should == 1
      f = File.open  filename
      output =  f.read
      output.should include gf.noid
      output.should include @user.login
      gf.destroy
    end
  end
end
