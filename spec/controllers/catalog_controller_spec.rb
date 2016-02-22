# frozen_string_literal: true
require 'spec_helper'

describe CatalogController, type: :controller do
  def solr_field(name)
    Solrizer.solr_name(name, :stored_searchable, type: :string)
  end

  def contributor_facet
    Solrizer.solr_name("contributor", :facetable)
  end

  before(:all) do
    GenericFile.create(title: ['Test Document PDF'], filename: ['test.pdf'], read_groups: ['public']).tap do |f|
      f.apply_depositor_metadata('mjg36')
      f.save
    end

    GenericFile.create(title: ['Test 2 Document'], filename: ['test2.doc'], contributor: ['Contrib2'], read_groups: ['public']).tap do |f|
      f.apply_depositor_metadata('mjg36')
      f.save
    end

    GenericFile.create.tap do |f|
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
      f.description = ["descriptiondescription"]
      f.format_label = ["format_labelformat_label"]
      f.full_text.content = "full_textfull_text"
      f.apply_depositor_metadata('mjg36')
      f.save
    end
  end

  before do
    allow_any_instance_of(GenericFile).to receive(:characterize_if_changed).and_yield
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end

  describe "#index" do
    describe "term search" do
      it "finds pdf files" do
        xhr :get, :index, q: "pdf"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("title"))[0]).to eql('Test Document PDF')
      end
      it "finds a file by title" do
        xhr :get, :index, q: "titletitle"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("title"))[0]).to eql('titletitle')
      end
      it "finds a file by tag" do
        xhr :get, :index, q: "tagtag"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("tag"))[0]).to eql('tagtag')
      end
      it "finds a file by subject" do
        xhr :get, :index, q: "subjectsubject"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("subject"))[0]).to eql('subjectsubject')
      end
      it "finds a file by creator" do
        xhr :get, :index, q: "creatorcreator"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("creator"))[0]).to eql('creatorcreator')
      end
      it "finds a file by contributor" do
        xhr :get, :index, q: "contributorcontributor"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("contributor"))[0]).to eql('contributorcontributor')
      end
      it "finds a file by publisher" do
        xhr :get, :index, q: "publisherpublisher"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("publisher"))[0]).to eql('publisherpublisher')
      end
      it "finds a file by based_near" do
        xhr :get, :index, q: "based_nearbased_near"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("based_near"))[0]).to eql('based_nearbased_near')
      end
      it "finds a file by language" do
        xhr :get, :index, q: "languagelanguage"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("language"))[0]).to eql('languagelanguage')
      end
      it "finds a file by resource_type" do
        xhr :get, :index, q: "resource_typeresource_type"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("resource_type"))[0]).to eql('resource_typeresource_type')
      end
      it "finds a file by format_label" do
        xhr :get, :index, q: "format_labelformat_label"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("file_format"))[0]).to eql('format_labelformat_label')
      end
      it "finds a file by description" do
        xhr :get, :index, q: "descriptiondescription"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("description"))[0]).to eql('descriptiondescription')
      end
      it "finds a file by full_text" do
        xhr :get, :index, q: "full_textfull_text"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
      end
      it "finds a file by depositor" do
        xhr :get, :index, q: "mjg36"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(3)
      end
      it "finds a file by depositor in advanced search" do
        xhr :get, :index, depositor: "mjg36", search_field: "advanced"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(3)
      end
    end
    describe "facet search" do
      before do
        xhr :get, :index, q: "{f=#{contributor_facet}}Contrib2"
      end
      it "finds facet files" do
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
      end
    end
    describe "user with group search" do
      before do
        allow_any_instance_of(User).to receive(:groups).and_return(['umg/personal.testuser.testgroup'])
        xhr :get, :index, q: "{f=#{contributor_facet}}Contrib2"
      end
      it "finds facet files" do
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
      end
    end
  end
end
