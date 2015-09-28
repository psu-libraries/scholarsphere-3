require 'spec_helper'

describe My::FilesController, type: :controller do
  routes { Sufia::Engine.routes }
  let(:user) { FactoryGirl.find_or_create(:archivist) }
  let(:strategy) do
    strategy = Devise::Strategies::HttpHeaderAuthenticatable.new(nil)
    allow(strategy).to receive(:request) { request }
    strategy
  end
  before do
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end
  # This doesn't really belong here, but it works for now
  describe "authenticate!" do
    before do
      allow(request).to receive(:headers).and_return('REMOTE_USER' => user.login)
    end
    it "populates LDAP attrs if user is new" do
      allow(User).to receive(:find_by_login).with(user.login).and_return(nil)
      expect(User).to receive(:create).with(login: user.login, email: user.login).once.and_return(user)
      expect_any_instance_of(User).to receive(:populate_attributes).once
      expect(strategy).to be_valid
      expect(strategy.authenticate!).to eq(:success)
      sign_in user
      get :index
    end
    it "does not populate LDAP attrs if user is not new" do
      allow(User).to receive(:find_by_login).with(user.login).and_return(user)
      expect(User).to receive(:create).with(login: user.login).never
      expect_any_instance_of(User).to receive(:populate_attributes).never
      expect(strategy).to be_valid
      expect(strategy.authenticate!).to eq(:success)
      sign_in user
      get :index
    end
  end
  describe "logged in user" do
    before do
      sign_in user
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end
    describe "#index" do
      include Sufia::Messages

      let(:batch_id)  { "batch_id" }
      let(:batch_id2) { "batch_id2" }
      let(:batch)       { double }
      let!(:generic_file) { GenericFile.new(id:"mine123", title:["mine"]) {|f| f.apply_depositor_metadata(user.login); f.update_index}}
      let!(:other_generic_file) { GenericFile.new(id:"other123", title:["other"]) {|f| f.apply_depositor_metadata("abc123"); f.update_index}}
      let(:user_results) do
        ActiveFedora::SolrService.instance.conn.get "select",
                                                    params: { fq: ["edit_access_group_ssim:public OR edit_access_person_ssim:#{user.user_key}"] }
      end

      before do
        allow(batch).to receive(:id).and_return(batch_id)
        User.batchuser.send_message(user, single_success(batch_id, batch), success_subject, sanitize_text = false)
        User.batchuser.send_message(user, multiple_success(batch_id2, [batch]), success_subject, sanitize_text = false)
        xhr :get, :index
      end
      it "returns an array of documents I can edit" do
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(user_results["response"]["numFound"])
        doc_ids = assigns(:document_list).map(&:id)
        expect(doc_ids).to include(generic_file.id)
        expect(doc_ids).not_to include(other_generic_file.id)
      end
      it "returns batches" do
        expect(assigns(:batches).count).to eq(2)
        expect(assigns(:batches)).to include("ss-" + batch_id)
        expect(assigns(:batches)).to include("ss-" + batch_id2)
      end
    end
    describe "term search" do
      def solr_field(name)
        Solrizer.solr_name(name, :stored_searchable, type: :string)
      end
      before do
        GenericFile.new(id: "abc123").tap do |f|
          f.title = ['titletitle']
          f.filename = ['filename.filename']
          f.read_groups = ['public']
          f.tag = ['tagtag']
          f.based_near = ["based_nearbased_near"]
          f.language = ["languagelanguage"]
          f.creator = ["creatorcreator"]
          f.contributor = ["contributorcontributor"]
          f.publisher = ["publisherpublisher"]
          f.subject = ["subjectsubject"]
          f.resource_type = ["resource_typeresource_type"]
          f.resource_type = ["resource_typeresource_type"]
          f.description = ["descriptiondescription"]
          f.format_label = ["format_labelformat_label"]
          f.apply_depositor_metadata(user.login)
          f.update_index
        end
      end
      it "finds a file by title" do
        xhr :get, :index, q: "titletitle"
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("title"))[0]).to eql('titletitle')
      end
      it "finds a file by tag" do
        xhr :get, :index, q: "tagtag"
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("tag"))[0]).to eql('tagtag')
      end
      it "finds a file by subject" do
        xhr :get, :index, q: "subjectsubject"
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("subject"))[0]).to eql('subjectsubject')
      end
      it "finds a file by creator" do
        xhr :get, :index, q: "creatorcreator"
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("creator"))[0]).to eql('creatorcreator')
      end
      it "finds a file by contributor" do
        xhr :get, :index, q: "contributorcontributor"
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("contributor"))[0]).to eql('contributorcontributor')
      end
      it "finds a file by publisher" do
        xhr :get, :index, q: "publisherpublisher"
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("publisher"))[0]).to eql('publisherpublisher')
      end
      it "finds a file by based_near" do
        xhr :get, :index, q: "based_nearbased_near"
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("based_near"))[0]).to eql('based_nearbased_near')
      end
      it "finds a file by language" do
        xhr :get, :index, q: "languagelanguage"
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("language"))[0]).to eql('languagelanguage')
      end
      it "finds a file by resource_type" do
        xhr :get, :index, q: "resource_typeresource_type"
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("resource_type"))[0]).to eql('resource_typeresource_type')
      end
      it "finds a file by format_label" do
        xhr :get, :index, q: "format_labelformat_label"
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("file_format"))[0]).to eql('format_labelformat_label')
      end
      it "finds a file by description" do
        xhr :get, :index, q: "descriptiondescription"
        expect(response).to be_success
        expect(response).to render_template('my/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("description"))[0]).to eql('descriptiondescription')
      end
    end
  end
  describe "not logged in as a user" do
    describe "#index" do
      it "returns an error" do
        xhr :post, :index
        expect(response).not_to be_success
      end
    end
  end
end
