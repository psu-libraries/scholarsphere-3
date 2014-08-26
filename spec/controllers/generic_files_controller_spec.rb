require 'spec_helper'

describe GenericFilesController do
  context "signed in user" do
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
  context "public user" do
    describe "#stats" do
      routes { Sufia::Engine.routes }

      let (:gf) { GenericFile.new(title: ['Test Document PDF'], filename: ['test.pdf'], read_groups:['public']).tap do |gf|
                  gf.apply_depositor_metadata("mjg36")
                  gf.save!
                end
              }
      before do
        mock_query = double('query')
        allow(mock_query).to receive(:for_path).and_return([
                                                               OpenStruct.new(date: '2014-01-01', pageviews: 4),
            OpenStruct.new(date: '2014-01-02', pageviews: 8),
            OpenStruct.new(date: '2014-01-03', pageviews: 6),
            OpenStruct.new(date: '2014-01-04', pageviews: 10),
            OpenStruct.new(date: '2014-01-05', pageviews: 2)])
        allow(mock_query).to receive(:map).and_return(mock_query.for_path.map(&:marshal_dump))
        profile = double('profile')
        allow(profile).to receive(:sufia__pageview).and_return(mock_query)
        allow(Sufia::Analytics).to receive(:profile).and_return(profile)

        download_query = double('query')
        allow(download_query).to receive(:for_file).and_return([OpenStruct.new(eventCategory: "Files", eventAction: "Downloaded", eventLabel: "sufia:123456789", totalEvents: "3")])
        allow(download_query).to receive(:map).and_return(download_query.for_file.map(&:marshal_dump))
        allow(profile).to receive(:sufia__download).and_return(download_query)
      end

      it "doesn't call has access on stats" do
        expect(GenericFilesController).not_to receive(:has_access?)
        get :stats, id: gf.noid
      end
    end
  end
end
