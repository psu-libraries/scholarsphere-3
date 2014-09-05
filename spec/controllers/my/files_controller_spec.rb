require 'spec_helper'

include Sufia::Messages

describe My::FilesController do
  routes { Sufia::Engine.routes }
  before do
    User.any_instance.stub(:groups).and_return([])
  end
  # This doesn't really belong here, but it works for now
  describe "authenticate!" do
    let (:user) {FactoryGirl.find_or_create(:archivist)}
    before(:each) do
      request.stub(:headers).and_return('REMOTE_USER' => user.login)
      @strategy = Devise::Strategies::HttpHeaderAuthenticatable.new(nil)
      @strategy.stub(request: request)
    end
    after(:each) do
      user.delete
    end
    it "should populate LDAP attrs if user is new" do
      User.stub(:find_by_login).with(user.login).and_return(nil)
      User.should_receive(:create).with(login: user.login, email:user.login).once.and_return(user)
      User.any_instance.should_receive(:populate_attributes).once
      @strategy.should be_valid
      @strategy.authenticate!.should == :success
      sign_in user
      get :index
    end
    it "should not populate LDAP attrs if user is not new" do
      User.stub(:find_by_login).with(user.login).and_return(user)
      User.should_receive(:create).with(login: user.login).never
      User.any_instance.should_receive(:populate_attributes).never
      @strategy.should be_valid
      @strategy.authenticate!.should == :success
      sign_in user
      get :index
    end
  end
  describe "logged in user" do
    let (:user) {FactoryGirl.find_or_create(:archivist)}
    before (:each) do
      sign_in user
      User.any_instance.stub(:groups).and_return([])
    end
    describe "#index" do
      let (:batch_noid) {"batch_noid"}
      let (:batch) {double}

      before (:each) do
        allow(batch).to receive(:noid).and_return(batch_noid)
        User.batchuser().send_message(user, single_success(batch_noid, batch), success_subject, sanitize_text = false)
        xhr :get, :index
      end
      it "should be a success" do
        response.should be_success
        response.should render_template('my/index')
      end
      it "should return an array of documents I can edit" do
        @user_results = ActiveFedora::SolrService.instance.conn.get "select", params:{fq:["edit_access_group_ssim:public OR edit_access_person_ssim:#{user.user_key}"]}
        assigns(:document_list).count.should eql(@user_results["response"]["numFound"])
      end
      it "returns batches" do
        expect(assigns(:batches).count).to eq(1)
        expect(assigns(:batches).first).to eq("ss-"+batch_noid)
      end
    end
    describe "term search" do
      before (:each) do
        @gf1 =  GenericFile.new(title: ['titletitle'], filename: ['filename.filename'], read_groups:['public'], tag: 'tagtag',
                         based_near: ["based_nearbased_near"], language: ["languagelanguage"],
                         creator: ["creatorcreator"], contributor: ["contributorcontributor"], publisher: ["publisherpublisher"],
                         subject: ["subjectsubject"], resource_type: ["resource_typeresource_type"], resource_type: ["resource_typeresource_type"])
        @gf1.description = ["descriptiondescription"]
        @gf1.format_label = ["format_labelformat_label"]
        @gf1.apply_depositor_metadata(user.login)
        @gf1.save
      end
      it "should find a file by title" do
        xhr :get, :index, q:"titletitle"
        response.should be_success
        response.should render_template('my/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__title_tesim')[0].should eql('titletitle')
      end
      it "should find a file by tag" do
        xhr :get, :index, q:"tagtag"
        response.should be_success
        response.should render_template('my/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__tag_tesim')[0].should eql('tagtag')
      end
      it "should find a file by subject" do
        xhr :get, :index, q:"subjectsubject"
        response.should be_success
        response.should render_template('my/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__subject_tesim')[0].should eql('subjectsubject')
      end
      it "should find a file by creator" do
        xhr :get, :index, q:"creatorcreator"
        response.should be_success
        response.should render_template('my/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__creator_tesim')[0].should eql('creatorcreator')
      end
      it "should find a file by contributor" do
        xhr :get, :index, q:"contributorcontributor"
        response.should be_success
        response.should render_template('my/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__contributor_tesim')[0].should eql('contributorcontributor')
      end
      it "should find a file by publisher" do
        xhr :get, :index, q:"publisherpublisher"
        response.should be_success
        response.should render_template('my/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__publisher_tesim')[0].should eql('publisherpublisher')
      end
      it "should find a file by based_near" do
        xhr :get, :index, q:"based_nearbased_near"
        response.should be_success
        response.should render_template('my/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__based_near_tesim')[0].should eql('based_nearbased_near')
      end
      it "should find a file by language" do
        xhr :get, :index, q:"languagelanguage"
        response.should be_success
        response.should render_template('my/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__language_tesim')[0].should eql('languagelanguage')
      end
      it "should find a file by resource_type" do
        xhr :get, :index, q:"resource_typeresource_type"
        response.should be_success
        response.should render_template('my/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__resource_type_tesim')[0].should eql('resource_typeresource_type')
      end
      it "should find a file by format_label" do
        xhr :get, :index, q:"format_labelformat_label"
        response.should be_success
        response.should render_template('my/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'file_format_tesim')[0].should eql('format_labelformat_label')
      end
      it "should find a file by description" do
        xhr :get, :index, q:"descriptiondescription"
        response.should be_success
        response.should render_template('my/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__description_tesim')[0].should eql('descriptiondescription')
      end
    end
  end
  describe "not logged in as a user" do
    describe "#index" do
      it "should return an error" do
        xhr :post, :index
        response.should_not be_success
      end
    end
  end
end
