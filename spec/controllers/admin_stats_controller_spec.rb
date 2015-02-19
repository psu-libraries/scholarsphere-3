require 'spec_helper'

describe Admin::StatsController, type: :controller do
  let(:user1) { FactoryGirl.find_or_create(:user) }
  let(:user2) { FactoryGirl.find_or_create(:archivist) }
  
  before do
    allow(user1).to receive(:groups).and_return(['umg/up.dlt.scholarsphere-admin-viewers'])
    allow(user2).to receive(:groups).and_return(['umg/up.dlt.some-other-group'])
  end

  describe "statistics page" do
    render_views
    before do
      sign_in user1
    end

    it 'allows an authorized user to view the page' do
      get :index
      expect(response).to be_success
      expect(response.body).to include('Statistics for ScholarSphere')
      expect(response.body).to include('Total ScholarSphere Users')
    end

    describe "querying user_stats" do
      it "defaults to latest 5 users" do
        get :index
        expect(assigns[:recent_users]).to eq(User.order('created_at DESC').limit(5).select('display_name, login, created_at, department'))
      end
      it "allows queries against user_stats" do
        expect(User).to receive(:where).with('id' => user1.id).once.and_return([user1])
        expect(User).to receive(:where).with('created_at >= ?',  1.days.ago.strftime("%Y-%m-%d")).and_return([user2])
        get :index, users_stats: {start_date:1.days.ago.strftime("%Y-%m-%d")}
        expect(assigns[:recent_users]).to eq([user2])
      end
    end

    describe "files_count" do
      let(:original_files_count) do
        poltergeist = GenericFile.new
        poltergeist.apply_depositor_metadata(user1)
        poltergeist.save
        original_files_count = GenericFile.count
        ActiveFedora::SolrService.instance.conn.delete_by_id(poltergeist.id)
        original_files_count
      end
      it "should provide accurate files_count, ensuring that solr deletes have been expunged first" do
        get :index
        expect(assigns[:files_count][:total]).to eq(original_files_count - 1)
      end
    end

    describe "counts" do
      before do
        GenericFile.new.tap do |f|
          f.apply_depositor_metadata(user1.user_key)
          f.save
        end
        GenericFile.new.tap do |f|
          f.apply_depositor_metadata(user1.user_key)
          f.read_groups= ['public']
          f.save
        end
        GenericFile.new.tap do |f|
          f.apply_depositor_metadata(user1.user_key)
          f.read_groups= ['registered']
          f.save
        end
        Collection.new.tap do |c|
          c.title = "test"
          c.apply_depositor_metadata(user1.user_key)
          c.save
        end
      end

      it "includes files but not collections" do
        get :index
        expect(assigns[:files_count][:total]).to eq(3)
        expect(assigns[:files_count][:public]).to eq(1)
        expect(assigns[:files_count][:psu]).to eq(1)
        expect(assigns[:files_count][:private]).to eq(1)
      end
    end

  end
end
