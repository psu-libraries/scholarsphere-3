# frozen_string_literal: true
require "rails_helper"

describe My::WorksController, type: :controller do
  include FactoryHelpers
  routes { Sufia::Engine.routes }

  let(:user) { create(:archivist) }

  describe "logged in user" do
    before do
      allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end

    describe "#index" do
      let!(:work)       { create(:file, depositor: user.login) }
      let!(:other_work) { create(:file) }
      let(:user_results) do
        ActiveFedora::SolrService.instance.conn.get "select",
                                                    params: { fq: ["edit_access_group_ssim:public OR edit_access_person_ssim:#{user.user_key}"] }
      end

      context "with a standard request" do
        before { xhr :get, :index }

        it "returns an array of documents I can edit" do
          expect(response).to be_success
          expect(response).to render_template("my/index")
          expect(assigns(:document_list).count).to eql(user_results["response"]["numFound"])
          doc_ids = assigns(:document_list).map(&:id)
          expect(doc_ids).to include(work.id)
          expect(doc_ids).not_to include(other_work.id)
        end
      end

      describe "specifying a collection to add" do
        let(:incorporate_collection) { create(:collection) }

        before { get :index, add_files_to_collection: collection }

        subject { assigns(:incorporate_collection_presenter) }

        context "when the collection exists" do
          let(:collection) { incorporate_collection.id }
          it { is_expected.to be_kind_of(CollectionPresenter) }
        end

        context "with a null collection to add" do
          let(:collection) { "" }
          it { is_expected.to be_nil }
        end

        context "with a non-existent collection to add" do
          let(:collection) { "idontexist" }
          it { is_expected.to be_nil }
        end
      end
    end

    describe "term search" do
      let!(:file_set) { build(:file_set, id: "fs") }
      let!(:work)     { build(:public_work, :with_complete_metadata, members: [file_set], depositor: "archivist1", id: "1234") }

      let(:file) { mock_file_factory(format_label: ["format_labelformat_label"]) }

      before do
        allow(file_set).to receive(:original_file).and_return(file)
        allow(work).to receive(:representative).and_return(file_set)
        ActiveFedora::Cleaner.cleanout_solr
        index_file_set(file_set)
        index_work(work)
      end
      it "finds a file by title" do
        xhr :get, :index, q: "titletitle"
        expect(response).to be_success
        expect(response).to render_template("my/index")
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("title"))[0]).to eql("titletitle")
      end
      it "finds a file by keyword" do
        xhr :get, :index, q: "tagtag"
        expect(response).to be_success
        expect(response).to render_template("my/index")
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("keyword"))[0]).to eql("tagtag")
      end
      it "finds a file by subject" do
        xhr :get, :index, q: "subjectsubject"
        expect(response).to be_success
        expect(response).to render_template("my/index")
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("subject"))[0]).to eql("subjectsubject")
      end
      it "finds a file by creator" do
        xhr :get, :index, q: "creatorcreator"
        expect(response).to be_success
        expect(response).to render_template("my/index")
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("creator"))[0]).to eql("creatorcreator")
      end
      it "finds a file by contributor" do
        xhr :get, :index, q: "contributorcontributor"
        expect(response).to be_success
        expect(response).to render_template("my/index")
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("contributor"))[0]).to eql("contributorcontributor")
      end
      it "finds a file by publisher" do
        xhr :get, :index, q: "publisherpublisher"
        expect(response).to be_success
        expect(response).to render_template("my/index")
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("publisher"))[0]).to eql("publisherpublisher")
      end
      it "finds a file by based_near" do
        xhr :get, :index, q: "based_nearbased_near"
        expect(response).to be_success
        expect(response).to render_template("my/index")
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("based_near"))[0]).to eql("based_nearbased_near")
      end
      it "finds a file by language" do
        xhr :get, :index, q: "languagelanguage"
        expect(response).to be_success
        expect(response).to render_template("my/index")
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("language"))[0]).to eql("languagelanguage")
      end
      it "finds a file by resource_type" do
        xhr :get, :index, q: "resource_typeresource_type"
        expect(response).to be_success
        expect(response).to render_template("my/index")
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("resource_type"))[0]).to eql("resource_typeresource_type")
      end
      it "finds a file by format_label" do
        xhr :get, :index, q: "format_labelformat_label"
        expect(response).to be_success
        expect(response).to render_template("my/index")
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("file_format"))[0]).to eql("plain (format_labelformat_label)")
      end
      it "finds a file by description" do
        xhr :get, :index, q: "descriptiondescription"
        expect(response).to be_success
        expect(response).to render_template("my/index")
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("description"))[0]).to eql("descriptiondescription")
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
