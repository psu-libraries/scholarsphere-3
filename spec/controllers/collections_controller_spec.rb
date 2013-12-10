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

describe CollectionsController do
  before(:each) { @routes = Hydra::Collections::Engine.routes }
  before do
    controller.stub(:has_access?).and_return(true)

    @user = FactoryGirl.find_or_create(:user)
    sign_in @user
    User.any_instance.stub(:groups).and_return([])
  end

  after (:all) do
    Collection.destroy_all
    GenericFile.destroy_all
    User.destroy_all
  end

  describe '#new' do
    it 'should assign @collection' do
      get :new
      assigns(:collection).should be_kind_of(Collection)
    end
  end
  
  describe '#create' do
    it "should create a Collection" do
      controller.should_receive(:has_access?).and_return(true)
      old_count = Collection.count
      post :create, collection: {title: "My First Collection ", description: "The Description\r\n\r\nand more"}
      Collection.count.should == old_count+1
    end
    it "should create a Collection with files I can access" do
      @asset1 = GenericFile.new(title: "First of the Assets")
      @asset1.apply_depositor_metadata(@user.user_key)
      @asset1.save
      @asset2 = GenericFile.new(title: "Second of the Assets", depositor:@user.user_key)
      @asset2.apply_depositor_metadata(@user.user_key)
      @asset2.save
      @asset3 = GenericFile.new(title: "Third of the Assets", depositor:'abc')
      @asset3.apply_depositor_metadata('abc')
      @asset3.save
      controller.should_receive(:has_access?).and_return(true)
      old_count = Collection.count
      post :create, collection: {title: "My own Collection ", description: "The Description\r\n\r\nand more"}, batch_document_ids:[@asset1.id, @asset2.id, @asset3.id]
      Collection.count.should == old_count+1
      collection = assigns(:collection)
      collection.members.should include (@asset1)
      collection.members.should include (@asset2)
      collection.members.should_not include (@asset3)
      @asset1.destroy
      @asset2.destroy
      @asset3.destroy
    end

    it "should add docs to collection if batch ids provided and add the collection id to the documents int he colledction" do
      @asset1 = GenericFile.new(title: "First of the Assets")
      @asset1.apply_depositor_metadata(@user.user_key)
      @asset1.save
      post :create, batch_document_ids: [@asset1.id], collection: {title: "My Secong Collection ", description: "The Description\r\n\r\nand more"}
      assigns[:collection].members.should == [@asset1]
      asset_results = Blacklight.solr.get "select", params:{fq:["id:\"#{@asset1.id}\""],fl:['id',Solrizer.solr_name(:collection)]}
      asset_results["response"]["numFound"].should == 1
      doc = asset_results["response"]["docs"].first
      doc["id"].should == @asset1.id
      afterupdate = GenericFile.find(@asset1.pid)
      doc[Solrizer.solr_name(:collection)].should == afterupdate.to_solr[Solrizer.solr_name(:collection)]
    end

  end

  describe "#update" do
    before do
      @collection = Collection.new
      @collection.apply_depositor_metadata(@user.user_key)
      @collection.save
      @asset1 = GenericFile.new(title: "First of the Assets")
      @asset1.apply_depositor_metadata(@user.user_key)
      @asset1.save
      @asset2 = GenericFile.new(title: "Second of the Assets", depositor:@user.user_key)
      @asset2.apply_depositor_metadata(@user.user_key)
      @asset2.save
      @asset3 = GenericFile.new(title: "Third of the Assets", depositor:'abc')
      @asset3.apply_depositor_metadata(@user.user_key)
      @asset3.save
    end
    after do
      @collection.destroy
      @asset1.destroy
      @asset2.destroy
      @asset3.destroy
    end

    it "should set collection on members" do
      put :update, id: @collection.id, collection: {members:"add"}, batch_document_ids:[@asset3.pid,@asset1.pid, @asset2.pid]
      response.should redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.noid)
      assigns[:collection].members.map{|m| m.pid}.sort.should == [@asset2, @asset3, @asset1].map {|m| m.pid}.sort
      asset_results = Blacklight.solr.get "select", params:{fq:["id:\"#{@asset2.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
      asset_results["response"]["numFound"].should == 1
      doc = asset_results["response"]["docs"].first
      doc["id"].should == @asset2.id
      afterupdate = GenericFile.find(@asset2.pid)
      doc[Solrizer.solr_name(:collection)].should == afterupdate.to_solr[Solrizer.solr_name(:collection)]
      put :update, id: @collection.id, collection: {members:"remove"}, batch_document_ids:[@asset2]
      asset_results = Blacklight.solr.get "select", params:{fq:["id:\"#{@asset2.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
      asset_results["response"]["numFound"].should == 1
      doc = asset_results["response"]["docs"].first
      doc["id"].should == @asset2.pid
      afterupdate = GenericFile.find(@asset2.pid)
      doc[Solrizer.solr_name(:collection)].should be_nil
    end
  end

  describe "#show" do
    before do
      @asset1 = GenericFile.new(title: "First of the Assets")
      @asset1.apply_depositor_metadata(@user.user_key)
      @asset1.save
      @asset2 = GenericFile.new(title: "Second of the Assets", depositor:@user.user_key)
      @asset2.apply_depositor_metadata(@user.user_key)
      @asset2.save
      @asset3 = GenericFile.new(title: "Third of the Assets", depositor:@user.user_key)
      @asset3.apply_depositor_metadata(@user.user_key)
      @asset3.save
      @asset4 = GenericFile.new(title: "Third of the Assets", depositor:@user.user_key)
      @asset4.apply_depositor_metadata(@user.user_key)
      @asset4.save
      @collection = Collection.new
      @collection.title = "My collection"
      @collection.description = "My incredibly detailed description of the collection"
      @collection.apply_depositor_metadata(@user.user_key)
      @collection.members = [@asset1,@asset2,@asset3]
      @collection.save
      controller.stub(:authorize!).and_return(true)
      controller.stub(:apply_gated_search)
    end
    it "should return the collection and its members" do
      get :show, id: @collection.id
      assigns[:collection].title.should == @collection.title
      ids = assigns[:member_docs].map {|d| d.id}
      ids.should include @asset1.pid
      ids.should include @asset2.pid
      ids.should include @asset3.pid
      ids.should_not include @asset4.pid
    end
    it "should query the collection members" do
      pending "The query isn't working here for some reason.  This is covered by a test in features/collection_spec.rb"
      get :show, id: @collection.id, cq:@asset1.title, id: @collection.pid
      assigns[:collection].title.should == @collection.title
      ids = assigns[:member_docs].map {|d| d.id}
      ids.should include @asset1.pid
      ids.should_not include @asset2.pid
      ids.should_not include @asset3.pid
    end
    context "signed out" do
      before do
        sign_out @user
      end
      it "should not show me files in the collection" do
        get :show, id: @collection.id
        assigns[:member_docs].count.should == 0
      end
    end
  end
end
