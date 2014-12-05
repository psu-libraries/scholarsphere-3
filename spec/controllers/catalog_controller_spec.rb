require 'spec_helper'

describe CatalogController, :type => :controller do
  before do
    allow_any_instance_of(GenericFile).to receive(:characterize_if_changed).and_yield
    @user = FactoryGirl.find_or_create(:user)
    sign_in @user
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end
  after do
    @user.delete
  end
  describe "#index" do
    before(:each) do
      @gf1 =  GenericFile.new(title: ['Test Document PDF'], filename: ['test.pdf'], read_groups:['public'])
      @gf1.apply_depositor_metadata('mjg36')
      @gf1.save
      @gf2 =  GenericFile.new(title: ['Test 2 Document'], filename: ['test2.doc'], contributor: ['Contrib2'], read_groups:['public'])
      @gf2.apply_depositor_metadata('mjg36')
      @gf2.save
      @gf3 =  GenericFile.new(title: ['titletitle'], filename: ['filename.filename'], read_groups:['public'], tag: ['tagtag'],
                       based_near: ["based_nearbased_near"], language: ["languagelanguage"],
                       creator: ["creatorcreator"], contributor: ["contributorcontributor"], publisher: ["publisherpublisher"],
                       subject: ["subjectsubject"], resource_type: ["resource_typeresource_type"])
      @gf3.description = ["descriptiondescription"]
      @gf3.format_label = ["format_labelformat_label"]
      @gf3.full_text.content = "full_textfull_text"
      @gf3.apply_depositor_metadata('mjg36')
      @gf3.save
    end
    describe "term search" do
      it "should find pdf files" do
        xhr :get, :index, q:"pdf"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'desc_metadata__title_tesim')[0]).to eql('Test Document PDF')
      end
      it "should find a file by title" do
        xhr :get, :index, q:"titletitle"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'desc_metadata__title_tesim')[0]).to eql('titletitle')
      end
      it "should find a file by tag" do
        xhr :get, :index, q:"tagtag"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'desc_metadata__tag_tesim')[0]).to eql('tagtag')
      end
      it "should find a file by subject" do
        xhr :get, :index, q:"subjectsubject"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'desc_metadata__subject_tesim')[0]).to eql('subjectsubject')
      end
      it "should find a file by creator" do
        xhr :get, :index, q:"creatorcreator"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'desc_metadata__creator_tesim')[0]).to eql('creatorcreator')
      end
      it "should find a file by contributor" do
        xhr :get, :index, q:"contributorcontributor"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'desc_metadata__contributor_tesim')[0]).to eql('contributorcontributor')
      end
      it "should find a file by publisher" do
        xhr :get, :index, q:"publisherpublisher"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'desc_metadata__publisher_tesim')[0]).to eql('publisherpublisher')
      end
      it "should find a file by based_near" do
        xhr :get, :index, q:"based_nearbased_near"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'desc_metadata__based_near_tesim')[0]).to eql('based_nearbased_near')
      end
      it "should find a file by language" do
        xhr :get, :index, q:"languagelanguage"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'desc_metadata__language_tesim')[0]).to eql('languagelanguage')
      end
      it "should find a file by resource_type" do
        xhr :get, :index, q:"resource_typeresource_type"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'desc_metadata__resource_type_tesim')[0]).to eql('resource_typeresource_type')
      end
      it "should find a file by format_label" do
        xhr :get, :index, q:"format_labelformat_label"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'file_format_tesim')[0]).to eql('format_labelformat_label')
      end
      it "should find a file by description" do
        xhr :get, :index, q:"descriptiondescription"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(:'desc_metadata__description_tesim')[0]).to eql('descriptiondescription')
      end
      it "should find a file by full_text" do
        xhr :get, :index, q:"full_textfull_text"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
      end
      it "should find a file by depositor" do
        xhr :get, :index, q:"mjg36"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(3)
      end
      it "should find a file by depositor in advanced search" do
        xhr :get, :index, depositor:"mjg36", search_field: "advanced"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(3)
      end
    end
    describe "facet search" do
      before do
        xhr :get, :index, q:"{f=desc_metadata__contributor_facet}Contrib2"
      end
      it "should find facet files" do
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
      end
    end
    describe "user with group search" do
      before do
        allow_any_instance_of(User).to receive(:groups).and_return(['umg/personal.testuser.testgroup'])
        xhr :get, :index, q:"{f=desc_metadata__contributor_facet}Contrib2"
      end
      it "should find facet files" do
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
      end
    end
  end

end
