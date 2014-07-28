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

describe GenericFilesController do
  before do
    Hydra::LDAP.connection.stub(:get_operation_result).and_return(OpenStruct.new({code:0, message:"Success"}))
    Hydra::LDAP.stub(:does_user_exist?).and_return(true)
    @user = FactoryGirl.find_or_create(:jill)
    sign_in @user
    User.any_instance.stub(:groups).and_return([])
  end
  describe "#create" do
    before do
      @file_count = GenericFile.count
      @mock = GenericFile.new({pid: 'test:123'})
      GenericFile.stub(:new).and_return(@mock)
    end
    after do
      begin
        Batch.find("sample:batch_id").delete
      rescue
      end
      @mock.delete unless @mock.inner_object.class == ActiveFedora::UnsavedDigitalObject
    end

    it "should spawn a content deposit event job" do
      file = fixture_file_upload('/world.png','image/png')
      s1 = double('one')
      ContentDepositEventJob.should_receive(:new).with('test:123', 'jilluser').and_return(s1)
      Sufia.queue.should_receive(:push).with(s1).once

      s2 = double('two')
      CharacterizeJob.should_receive(:new).with('test:123').and_return(s2)
      Sufia.queue.should_receive(:push).with(s2).once
      xhr :post, :create, files:[file], Filename:"The world", batch_id: "sample:batch_id", permission:{"group"=>{"public"=>"read"} }, terms_of_service:"1"
    end

    it "should create and save a file asset from the given params" do
      file = fixture_file_upload('/world.png','image/png')
      xhr :post, :create, files:[file], Filename:"The world", batch_id: "sample:batch_id", permission:{"group"=>{"public"=>"read"} }, terms_of_service:"1"
      response.should be_success
      GenericFile.count.should == @file_count + 1

      saved_file = GenericFile.find('test:123')

      # This is confirming that the correct file was attached
      saved_file.label.should == 'world.png'
      saved_file.content.checksum.should == 'f794b23c0c6fe1083d0ca8b58261a078cd968967'
      saved_file.content.dsChecksumValid.should be_truthy

      # Confirming that date_uploaded and date_modified were set
      saved_file.date_uploaded.should_not be nil
      saved_file.date_modified.should_not be nil
    end

    it "should record on_behalf_of" do
      file = fixture_file_upload('/world.png','image/png')
      xhr :post, :create, files:[file], Filename:"The world", batch_id: "sample:batch_id", on_behalf_of:'carolyn', terms_of_service:"1"
      response.should be_success
      saved_file = GenericFile.find('test:123')
      saved_file.on_behalf_of.should == 'carolyn'
    end

    it "should record what user created the first version of content" do
      GenericFile.any_instance.stub(:to_solr).and_return({ id: "test:123" })
      file = fixture_file_upload('/world.png','image/png')
      xhr :post, :create, files: [file], Filename: "The world", batch_id: "sample:batch_id", permission: {"group"=>{"public"=>"read"} }, terms_of_service: "1"
      saved_file = GenericFile.find('test:123')
      version = saved_file.content.latest_version
      version.versionID.should == "content.0"
      saved_file.content.version_committer(version).should == @user.login
    end

    it "should create batch associations from batch_id" do
      Sufia.config.stub(:id_namespace).and_return('sample')
      file = fixture_file_upload('/world.png','image/png')
      controller.stub(:add_posted_blob_to_asset)
      xhr :post, :create, files:[file], Filename:"The world", batch_id: "sample:batch_id", permission:{"group"=>{"public"=>"read"} }, terms_of_service:"1"
      lambda {Batch.find("sample:batch_id")}.should raise_error(ActiveFedora::ObjectNotFoundError) # The controller shouldn't actually save the Batch
      b = Batch.create(pid: "sample:batch_id")
      b.generic_files.first.pid.should == "test:123"
    end
    it "should set the depositor id" do
      file = fixture_file_upload('/world.png','image/png')
      xhr :post, :create, files: [file], Filename: "The world", batch_id: "sample:batch_id", permission: {"group"=>{"public"=>"read"} }, terms_of_service: "1"
      response.should be_success

      saved_file = GenericFile.find('test:123')
      # This is confirming that apply_depositor_metadata recorded the depositor
      saved_file.properties.depositor.should == ['jilluser']
      saved_file.depositor.should == 'jilluser'
      saved_file.properties.to_solr.keys.should include('depositor_tesim')
      saved_file.properties.to_solr['depositor_tesim'].should == ['jilluser']
      saved_file.to_solr.keys.should include('depositor_tesim')
      saved_file.to_solr['depositor_tesim'].should == ['jilluser']
    end
    it "should call virus check" do
      GenericFile.any_instance.stub(:to_solr).and_return({ id: "foo:123" })
      file = fixture_file_upload('/world.png','image/png')
      s1 = double('one')
      ContentDepositEventJob.should_receive(:new).with('test:123','jilluser').and_return(s1)
      Sufia.queue.should_receive(:push).with(s1).once
      s2 = double('two')
      CharacterizeJob.should_receive(:new).with('test:123').and_return(s2)
      Sufia.queue.should_receive(:push).with(s2).once
      xhr :post, :create, files:[file], Filename:"The world", batch_id: "sample:batch_id", permission:{"group"=>{"public"=>"read"} }, terms_of_service:"1"
    end

    it "should error out of create and save after on continuos rsolr error" do
      GenericFile.any_instance.stub(:save).and_raise(RSolr::Error::Http.new({},{}))

      file = fixture_file_upload('/world.png','image/png')
      xhr :post, :create, files:[file], Filename:"The world", batch_id: "sample:batch_id", permission:{"group"=>{"public"=>"read"} }, terms_of_service:"1"
      response.body.should include("Error occurred while creating generic file.")
    end

  end

  describe "audit" do
    before do
      @generic_file = GenericFile.new
      @generic_file.add_file_datastream(File.new(Rails.root + 'spec/fixtures/world.png'), dsid:'content')
      @generic_file.apply_depositor_metadata('mjg36')
      @generic_file.save
    end
    after do
      @generic_file.delete
    end
    it "should return json with the result" do
      xhr :post, :audit, id:@generic_file.pid
      response.should be_success
      lambda { JSON.parse(response.body) }.should_not raise_error
      audit_results = JSON.parse(response.body).collect { |result| result["pass"] }
      audit_results.reduce(true) { |sum, value| sum && value }.should be_truthy
    end
  end

  describe "destroy" do
    before(:each) do
      @user = FactoryGirl.find_or_create(:jill)
      sign_in @user
      @generic_file = GenericFile.new
      @generic_file.apply_depositor_metadata(@user.login)
      @generic_file.save
    end
    after do
      @user.delete
    end
    it "should delete the file" do
      GenericFile.find(@generic_file.pid).should_not be_nil
      delete :destroy, id:@generic_file.pid
      lambda { GenericFile.find(@generic_file.pid) }.should raise_error(ActiveFedora::ObjectNotFoundError)
    end
    it "should spawn a content delete event job" do
      s2 = double('two')
      ContentDeleteEventJob.should_receive(:new).with(@generic_file.pid, @user.login).and_return(s2)
      Sufia.queue.should_receive(:push).with(s2).once
      delete :destroy, id:@generic_file.pid
    end
  end

  describe "update" do
    before do
      ClamAV.any_instance.stub(:scanfile).and_return(0)
      @generic_file = GenericFile.new
      @generic_file.apply_depositor_metadata(@user.login)
      @generic_file.save!
    end
    after do
      @generic_file.delete
    end

    it "should spawn a content update event job" do
      s2 = double('two')
      ContentUpdateEventJob.should_receive(:new).with(@generic_file.pid, @user.login).and_return(s2)
      Sufia.queue.should_receive(:push).with(s2).once
      @user = FactoryGirl.find_or_create(:jill)
      sign_in @user
      post :update, id:@generic_file.pid, generic_file:{title: ['new_title'], tag:[''], permissions:{new_user_name:{'archivist1'=>'edit'}}}
      @user.delete
    end

    it "should spawn a content new version event job" do
      s1 = double('one')
      ContentNewVersionEventJob.should_receive(:new).with(@generic_file.pid, @user.login).and_return(s1)
      Sufia.queue.should_receive(:push).with(s1).once
      s2 = double('two')
      CharacterizeJob.should_receive(:new).with(@generic_file.pid).and_return(s2)
      Sufia.queue.should_receive(:push).with(s2).once
      @user = FactoryGirl.find_or_create(:jill)
      sign_in @user

      file = fixture_file_upload('/world.png','image/png')
      post :update, id:@generic_file.pid, filedata:file, Filename:"The world", generic_file:{tag:[''],  permissions:{new_user_name:{'archivist1'=>'edit'}}}
      @user.delete
    end

    context "existing version" do
      let (:archivist) { FactoryGirl.find_or_create(:archivist)}
      let (:user) {FactoryGirl.find_or_create(:jill)}

      before do
        @generic_file.permissions = {user: {archivist.login =>'edit'}}
        @user = user
        actor = Sufia::GenericFile::Actor.new(@generic_file, @user)
        file = fixture_file_upload('/world.png','image/png')
        actor.create_content(file, file.original_filename, 'content')
      end
      after do
        archivist.destroy
        user.destroy
      end

      it "should record what user added a new version" do

        version1 = @generic_file.content.latest_version
        @generic_file.content.version_committer(version1).should == @user.login

        # other user uploads new version
        archivist = FactoryGirl.find_or_create(:archivist)
        sign_in archivist
        ContentUpdateEventJob.should_receive(:new).with(@generic_file.pid, archivist.login).never

        s2 = double('two')
        ContentNewVersionEventJob.should_receive(:new).with(@generic_file.pid, archivist.login).and_return(s2)
        Sufia.queue.should_receive(:push).with(s2).once
        s3 = double('three')
        CharacterizeJob.should_receive(:new).with(@generic_file.pid).and_return(s3)
        Sufia.queue.should_receive(:push).with(s3).once
        file = fixture_file_upload('/image.jp2','image/jp2')
        post :update, id:@generic_file.pid, filedata:file, Filename:"The new world", generic_file:{tag:[''] }
        edited_file = GenericFile.find(@generic_file.pid)
        version2 = edited_file.content.latest_version
        version2.versionID.should_not == version1.versionID
        edited_file.content.version_committer(version2).should == archivist.login
      end

      context "version of a another user" do

        before do
          actor = Sufia::GenericFile::Actor.new(@generic_file, archivist)
          file = fixture_file_upload('/image.jp2','image/jp2')
          actor.create_content(file, file.original_filename, 'content')
        end
        after do
          archivist.destroy
        end
        it "should record what user reverts a version" do
          version2 = @generic_file.content.latest_version

          # user restores his or her original version
          sign_in user
          ContentUpdateEventJob.should_receive(:new).with(@generic_file.pid, user.login).never

          s2 = double('two')
          ContentRestoredVersionEventJob.should_receive(:new).with(@generic_file.pid, user.login, 'content.0').and_return(s2)
          Sufia.queue.should_receive(:push).with(s2).once
          s3 = double('three')
          CharacterizeJob.should_receive(:new).with(@generic_file.pid).and_return(s3)
          Sufia.queue.should_receive(:push).with(s3)
          post :update, id:@generic_file.pid, revision:'content.0', generic_file:{tag:['']}

          restored_file = GenericFile.find(@generic_file.pid)
          version3 = restored_file.content.latest_version
          version3.versionID.should_not == version2.versionID
          restored_file.content.version_committer(version3).should == user.login
        end
      end

    end

    it "should add a new groups and users" do
      post :update, id:@generic_file.pid, generic_file:{tag:[''], permissions:{new_group_name:{'group1'=>'read'}, new_user_name:{'user1'=>'edit'}}}

      assigns[:generic_file].read_groups.should == ["group1"]
      assigns[:generic_file].edit_users.should include("user1", @user.login)
    end
    it "should update existing groups and users" do
      @generic_file.read_groups = ['group3']
      @generic_file.save
      post :update, id:@generic_file.pid, generic_file:{tag:[''], permissions:{ new_group_name:'', new_group_permission:'', new_user_name:'', new_user_permission:'', group:{'group3' =>'read'}}}

      assigns[:generic_file].read_groups.should == ["group3"]
    end
    it "should notify user when added to the list of file permissions" do
      #create or retrieve current user
      recipient = User.audituser
      #update file adding user to the permission set, triggering the notification
      post :update, id:@generic_file.pid, generic_file:{tag:[''], permissions:{new_user_name:{'audituser'=>'edit'}}}
      #test to see if user has received any messages
      recipient.mailbox.inbox.count.should == 1
    end
    it "should spawn a virus check" do
      s1 = double('one')
      ContentNewVersionEventJob.should_receive(:new).with(@generic_file.pid, @user.login).and_return(s1)
      Sufia.queue.should_receive(:push).with(s1).once
      s2 = double('two')
      CharacterizeJob.should_receive(:new).with(@generic_file.pid).and_return(s2)
      Sufia.queue.should_receive(:push).with(s2).once

      GenericFile.stub(:save).and_return({})
      ClamAV.any_instance.should_receive(:scanfile).and_return(0)
      @user = FactoryGirl.find_or_create(:jill)
      sign_in @user
      file = fixture_file_upload('/world.png','image/png')
      post :update, id:@generic_file.pid, filedata:file, Filename:"The world", generic_file:{tag:[''],  permissions:{new_user_name:{'archivist1'=>'edit'}}}
    end
  end

  describe "a file owned by someone else" do
    before(:each) do
      f = GenericFile.new(pid: 'scholarsphere:test5')
      f.apply_depositor_metadata('archivist1')
      f.set_title_and_label('world.png')
      f.add_file_datastream(File.new(Rails.root +  'spec/fixtures/world.png'))
      # grant public read access explicitly
      f.read_groups = ['public']
      f.save!
      @file = f
    end
    describe "edit" do
      it "should give me a flash error" do
        get :edit, id:"test5"
        response.should redirect_to(action: 'show')
        flash[:alert].should_not be_nil
        flash[:alert].should_not be_empty
        flash[:alert].should include("You do not have sufficient privileges to edit this document")
      end
    end
    describe "view" do
      it "should show me the file" do
        get :show, id:"test5"
        response.should_not redirect_to(action: 'show')
        flash[:alert].should be_nil
      end
    end
    describe "flash" do
      render_views
      it "should not let the user submit if they logout" do
        sign_out @user
        get :new
        response.should_not be_success
      end
      describe "failing audit" do
        before(:each) do
          ActiveFedora::RelsExtDatastream.any_instance.stub(:dsChecksumValid).and_return(false)
          @archivist = FactoryGirl.find_or_create(:archivist)
        end
        it "should display failing audits" do
          sign_out @user
          sign_in @archivist
          AuditJob.new(@file.pid, "RELS-EXT", @file.rels_ext.versionID).run
          get :show, id:"test5"
          response.body.should include('<span id="notify_number" class="overlay"> 1</span>') # notify should be 1 for failing job
          @archivist.mailbox.inbox[0].messages[0].subject.should == "Failing Audit Run"
        end
      end
    end
  end
end
