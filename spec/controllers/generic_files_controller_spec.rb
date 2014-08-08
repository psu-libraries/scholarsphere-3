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

    it "should record on_behalf_of" do
      file = fixture_file_upload('/world.png','image/png')
      xhr :post, :create, files:[file], Filename:"The world", batch_id: "sample:batch_id", on_behalf_of:'carolyn', terms_of_service:"1"
      response.should be_success
      saved_file = GenericFile.find('test:123')
      saved_file.on_behalf_of.should == 'carolyn'
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

  end

end
