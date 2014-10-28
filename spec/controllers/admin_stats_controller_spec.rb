require 'spec_helper'

describe Admin::StatsController do
  before do
    @user1 = FactoryGirl.find_or_create(:user)
    @user1.stub(:groups).and_return(['umg/up.dlt.scholarsphere-admin-viewers'])
    @user2 = FactoryGirl.find_or_create(:archivist)
    @user2.stub(:groups).and_return(['umg/up.dlt.some-other-group'])
  end

  after do
    @user1.delete
    @user2.delete
  end

  describe "statistics page" do
    render_views

    it 'allows an authorized user to view the page' do
      sign_in @user1
      get :index
      response.should be_success
      response.body.should include('Statistics for ScholarSphere')
      response.body.should include('Total ScholarSphere Users')
    end

    describe "querying user_stats" do
      it "defaults to latest 5 users" do
        sign_in @user1
        get :index
        assigns[:recent_users].should == User.order('created_at DESC').limit(5).select('display_name, login, created_at, department')
      end
      it "allows queries against user_stats" do
        sign_in @user1
        User.should_receive(:where).with('id' => @user1.id).once.and_return([@user1])
        User.should_receive(:where).with('created_at >= ?',  1.days.ago.strftime("%Y-%m-%d")).and_return([@user2])
        get :index, users_stats: {start_date:1.days.ago.strftime("%Y-%m-%d")}
        assigns[:recent_users].should == [@user2]
      end
    end

    describe "files_count" do
      before do
        @poltergeist = GenericFile.new
        @poltergeist.apply_depositor_metadata(@user1)
        @poltergeist.save
      end
      after do
        @poltergeist.delete
        ActiveFedora::SolrService.instance.conn.commit("expungeDeletes"=>true)
      end
      it "should provide accurate files_count, ensuring that solr deletes have been expunged first" do
        original_files_count = GenericFile.count
        ActiveFedora::SolrService.instance.conn.delete_by_id(@poltergeist.pid) # send delete message to solr without sending commit message
        sign_in @user1
        get :index
        assigns[:files_count][:total].should == original_files_count - 1
      end
    end

    describe "counts" do
      let!(:gf) { GenericFile.new.tap do |f|
                  f.apply_depositor_metadata(@user1.user_key)
                  f.save
                end }
      let!(:gf2) { GenericFile.new.tap do |f|
        f.apply_depositor_metadata(@user1.user_key)
        f.read_groups= ['public']
        f.save
      end }
      let!(:gf3) { GenericFile.new.tap do |f|
        f.apply_depositor_metadata(@user1.user_key)
        f.read_groups= ['registered']
        f.save
      end }

      # create a collection to add other items into the repository that should not get counted
      #  DO NOT REMOVE
      let!(:col) { Collection.new.tap do |c|
                  c.title = "test"
                  c.apply_depositor_metadata(@user1.user_key)
                  c.save
                end }
      after do
        gf.destroy
        gf2.destroy
        gf3.destroy
        col.destroy
      end

      it "counts file correctly" do
        get :index
        assigns[:files_count][:total].should == 3
        assigns[:files_count][:public].should == 1
        assigns[:files_count][:psu].should == 1
        assigns[:files_count][:private].should == 1
      end
    end

  end
end
