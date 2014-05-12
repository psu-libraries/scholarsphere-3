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

describe DashboardController do
  routes { Sufia::Engine.routes }
  before do
    User.any_instance.stub(:groups).and_return([])
  end
  # This doesn't really belong here, but it works for now
  describe "authenticate!" do
    before(:each) do
      @user = FactoryGirl.find_or_create(:archivist)
      request.stub(:headers).and_return('REMOTE_USER' => @user.login)
      @strategy = Devise::Strategies::HttpHeaderAuthenticatable.new(nil)
      @strategy.stub(request: request)
    end
    after(:each) do
      @user.delete
    end
    it "should populate LDAP attrs if user is new" do
      User.stub(:find_by_login).with(@user.login).and_return(nil)
      User.should_receive(:create).with(login: @user.login, email:@user.login).once.and_return(@user)
      User.any_instance.should_receive(:populate_attributes).once
      @strategy.should be_valid
      @strategy.authenticate!.should == :success
      sign_in @user
      get :index
    end
    it "should not populate LDAP attrs if user is not new" do
      User.stub(:find_by_login).with(@user.login).and_return(@user)
      User.should_receive(:create).with(login: @user.login).never
      User.any_instance.should_receive(:populate_attributes).never
      @strategy.should be_valid
      @strategy.authenticate!.should == :success
      sign_in @user
      get :index
    end
  end
  describe "logged in user" do
    before (:each) do
      @user = FactoryGirl.find_or_create(:archivist)
      sign_in @user
      User.any_instance.stub(:groups).and_return([])
    end
    describe "#index" do
      before (:each) do
        xhr :get, :index
      end
      it "should be a success" do
        response.should be_success
        response.should render_template('dashboard/index')
      end
      it "should return an array of documents I can edit" do
        @user_results = ActiveFedora::SolrService.instance.conn.get "select", params:{fq:["edit_access_group_ssim:public OR edit_access_person_ssim:#{@user.user_key}"]}
        assigns(:document_list).count.should eql(@user_results["response"]["numFound"])
      end
    end
    describe "term search" do
   before (:all) do
      @user = FactoryGirl.find_or_create(:archivist)
      @gf1 =  GenericFile.new(title: 'titletitle', filename:'filename.filename', read_groups:['public'], tag: 'tagtag', 
                       based_near:"based_nearbased_near", language:"languagelanguage", 
                       creator:"creatorcreator", contributor:"contributorcontributor", publisher: "publisherpublisher",
                       subject:"subjectsubject", resource_type:"resource_typeresource_type", resource_type:"resource_typeresource_type")
      @gf1.description = "descriptiondescription"
      @gf1.format_label = "format_labelformat_label"
      @gf1.apply_depositor_metadata(@user.login)
      @gf1.save
    end
    after (:all) do
      @gf1.delete
    end
      it "should find a file by title" do
        xhr :get, :index, q:"titletitle"
        response.should be_success
        response.should render_template('dashboard/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__title_tesim')[0].should eql('titletitle')
      end
      it "should find a file by tag" do
        xhr :get, :index, q:"tagtag"
        response.should be_success
        response.should render_template('dashboard/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__tag_tesim')[0].should eql('tagtag')
      end
      it "should find a file by subject" do
        xhr :get, :index, q:"subjectsubject"
        response.should be_success
        response.should render_template('dashboard/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__subject_tesim')[0].should eql('subjectsubject')
      end
      it "should find a file by creator" do
        xhr :get, :index, q:"creatorcreator"
        response.should be_success
        response.should render_template('dashboard/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__creator_tesim')[0].should eql('creatorcreator')
      end
      it "should find a file by contributor" do
        xhr :get, :index, q:"contributorcontributor"
        response.should be_success
        response.should render_template('dashboard/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__contributor_tesim')[0].should eql('contributorcontributor')
      end
      it "should find a file by publisher" do
        xhr :get, :index, q:"publisherpublisher"
        response.should be_success
        response.should render_template('dashboard/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__publisher_tesim')[0].should eql('publisherpublisher')
      end
      it "should find a file by based_near" do
        xhr :get, :index, q:"based_nearbased_near"
        response.should be_success
        response.should render_template('dashboard/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__based_near_tesim')[0].should eql('based_nearbased_near')
      end
      it "should find a file by language" do
        xhr :get, :index, q:"languagelanguage"
        response.should be_success
        response.should render_template('dashboard/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__language_tesim')[0].should eql('languagelanguage')
      end
      it "should find a file by resource_type" do
        xhr :get, :index, q:"resource_typeresource_type"
        response.should be_success
        response.should render_template('dashboard/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__resource_type_tesim')[0].should eql('resource_typeresource_type')
      end
      it "should find a file by format_label" do
        xhr :get, :index, q:"format_labelformat_label"
        response.should be_success
        response.should render_template('dashboard/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'file_format_tesim')[0].should eql('format_labelformat_label')
      end
      it "should find a file by description" do
        xhr :get, :index, q:"descriptiondescription"
        response.should be_success
        response.should render_template('dashboard/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__description_tesim')[0].should eql('descriptiondescription')
      end
      

      
    end


  end
  describe "not logged in as a user" do
    describe "#index" do
      it "should return an error" do
        xhr :post, :index
        response.should_not be_success
      end
    end
  end
end
