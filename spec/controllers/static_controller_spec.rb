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

describe StaticController do
  routes { Sufia::Engine.routes }
  describe "#mendeley" do
    render_views
    it "renders page" do
      get "mendeley"
      response.should be_success
      response.should render_template "layouts/sufia-one-column"
    end
    it "renders no layout with javascript" do
      get "mendeley" ,{format:"js"}
      response.should be_success
      response.should_not render_template "layouts/sufia-one-column"
    end
  end

  describe "#zotero" do
    render_views
    it "renders page" do
      get "zotero"
      response.should be_success
      response.should render_template "layouts/sufia-one-column"
    end
    it "renders no layout with javascript" do
      get "zotero" ,{format:"js"}
      response.should be_success
      response.should_not render_template "layouts/sufia-one-column"
    end
  end
end
