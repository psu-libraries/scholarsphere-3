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
    controller.stubs(:has_access?).returns(true)

    @user = FactoryGirl.find_or_create(:user)
    sign_in @user
    User.any_instance.stubs(:groups).returns([])
  end

  describe '#new' do
    it 'should assign @collection' do
      get :new
      assigns(:collection).should be_kind_of(Collection)
    end
  end
  
  describe '#create' do
    it "should create a Collection" do
      controller.expects(:has_access?).returns(true)
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
      controller.expects(:has_access?).returns(true)
      old_count = Collection.count
      post :create, collection: {title: "My own Collection ", description: "The Description\r\n\r\nand more"}, batch_document_ids:[@asset1.id, @asset2.id, @asset3.id]
      Collection.count.should == old_count+1
      collection = assigns(:collection)
      collection.members.should include (@asset1)
      collection.members.should include (@asset2)
      collection.members.should_not include (@asset3)
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
      controller.stubs(:authorize!).returns(true)
      controller.stubs(:apply_gated_search)
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
  end
end
