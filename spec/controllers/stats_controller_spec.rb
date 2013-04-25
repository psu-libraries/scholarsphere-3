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

describe StatsController do
  before do
    User.any_instance.stubs(:groups).returns(["umg/dlt.scholarsphere-admin-viewers"])
    User.any_instance.stubs(:name).returns("Jill Z. User")

    # GenericFile.any_instance.stubs(:characterize_if_changed).yields
    @user = FactoryGirl.find_or_create(:user)
    @user2 = FactoryGirl.find_or_create(:archivist)
    @user3 = FactoryGirl.find_or_create(:test_user_1)
    @user4 = FactoryGirl.find_or_create(:test_user_2)
    @user5 = FactoryGirl.find_or_create(:curator)
    sign_in @user
    sign_in @user2
    sign_in @user3
    sign_in @user4
    sign_in @user5

    # controller.stubs(:clear_session_user) ## Don't clear out the authenticated session
    @gf1 =  GenericFile.new(title:'Test Document PDF', filename:'test4.pdf', read_groups:['public'], format_label:['Portable Document Format'], creator:['curator1'])
    @gf1.apply_depositor_metadata(@user5.login)
    @gf1.save
    @gf2 =  GenericFile.new(title:'Test 2 Document', filename:'test2.docx', contributor:'Contrib2', read_groups:['public'], format_label:['Microsoft Word', 'FPX'], creator:['jilluser'] )
    @gf2.apply_depositor_metadata(@user.login)
    @gf2.save
    @gf3 =  GenericFile.new(title:'Test Document image', filename:'test6.jp2', read_groups:['public'], format_label:['Exchangeable Image File Format'], creator:['archivist1'])
    @gf3.apply_depositor_metadata(@user2.login)
    @gf3.save
    @gf4 =  GenericFile.new(title:'Test Text', filename:'test5.txt', contributor:'Contrib2', read_groups:['public'], format_label:['OpenDocument Text'], creator:['archivist1'])
    @gf4.apply_depositor_metadata(@user2.login)
    @gf4.save
    @gf5 =  GenericFile.new(title:'Test Text', filename:'test3.xls', contributor:'Contrib2', read_groups:['public'], creator:['tstem31'])
    @gf5.apply_depositor_metadata(@user3.login)
    @gf5.save
    @gf6 =  GenericFile.new(title:'Test Text', filename:'test1.txt', contributor:'Contrib2', read_groups:['public'], format_label:['OpenDocument Text'], creator:['testapp'])
    @gf6.apply_depositor_metadata(@user4.login)
    @gf6.save
  end
  after do
      @user.delete
      @user2.delete
      @user3.delete
      @user4.delete
      @user5.delete
      @gf1.delete
      @gf2.delete
      @gf3.delete
      @gf4.delete
      @gf5.delete
      @gf6.delete
    end

  describe "statistics page" do
    render_views
    it "renders the statstics list view" do
      get :list
      response.should_not redirect_to(root_path)
      response.body.should include('Statistics for ScholarSphere')
      response.body.should include('Total Scholarsphere Members')
    end
  end
end
