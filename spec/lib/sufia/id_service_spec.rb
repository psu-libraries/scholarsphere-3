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

require 'spec_helper'

describe Sufia::IdService do
  it "should respond to mint" do
    Sufia::IdService.should respond_to(:mint)
  end
  describe "mint" do
    before(:all) do
      @id = Sufia::IdService.mint
    end
    it "should create a unique id" do
      @id.should_not be_empty
    end
    it "should look like a ScholarSphere id" do
      @id.should match(/scholarsphere\:.{9}/)
    end
    it "should not mint the same id twice in a row" do
      other_id = Sufia::IdService.mint
      other_id.should_not == @id
    end
  end
end
