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

describe CatalogController do
  before(:all) do
    GenericFile.all.each(&:destroy)
  end
  before do
    GenericFile.any_instance.stub(:characterize_if_changed).and_yield
    @user = FactoryGirl.find_or_create(:user)
    sign_in @user
    User.any_instance.stub(:groups).and_return([])
  end
  after do
    @user.delete
  end
  describe "#index" do
    before (:all) do
      @gf1 =  GenericFile.new(title:'Test Document PDF', filename:'test.pdf', read_groups:['public'])
      @gf1.apply_depositor_metadata('mjg36')
      @gf1.save
      @gf2 =  GenericFile.new(title:'Test 2 Document', filename:'test2.doc', contributor:'Contrib2', read_groups:['public'])
      @gf2.apply_depositor_metadata('mjg36')
      @gf2.save
      @gf3 =  GenericFile.new(title: 'titletitle', filename:'filename.filename', read_groups:['public'], tag: 'tagtag',
                       based_near:"based_nearbased_near", language:"languagelanguage",
                       creator:"creatorcreator", contributor:"contributorcontributor", publisher: "publisherpublisher",
                       subject:"subjectsubject", resource_type:"resource_typeresource_type")
      @gf3.description = "descriptiondescription"
      @gf3.format_label = "format_labelformat_label"
      @gf3.full_text.content = "full_textfull_text"
      @gf3.apply_depositor_metadata('mjg36')
      @gf3.save
    end
    after (:all) do
      @gf1.delete
      @gf2.delete
      @gf3.delete
    end
    describe "term search" do
      it "should find pdf files" do
        xhr :get, :index, :q =>"pdf"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__title_tesim')[0].should eql('Test Document PDF')
      end
      it "should find a file by title" do
        xhr :get, :index, :q =>"titletitle"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__title_tesim')[0].should eql('titletitle')
      end
      it "should find a file by tag" do
        xhr :get, :index, :q =>"tagtag"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__tag_tesim')[0].should eql('tagtag')
      end
      it "should find a file by subject" do
        xhr :get, :index, :q =>"subjectsubject"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__subject_tesim')[0].should eql('subjectsubject')
      end
      it "should find a file by creator" do
        xhr :get, :index, :q =>"creatorcreator"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__creator_tesim')[0].should eql('creatorcreator')
      end
      it "should find a file by contributor" do
        xhr :get, :index, :q =>"contributorcontributor"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__contributor_tesim')[0].should eql('contributorcontributor')
      end
      it "should find a file by publisher" do
        xhr :get, :index, :q =>"publisherpublisher"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__publisher_tesim')[0].should eql('publisherpublisher')
      end
      it "should find a file by based_near" do
        xhr :get, :index, :q =>"based_nearbased_near"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__based_near_tesim')[0].should eql('based_nearbased_near')
      end
      it "should find a file by language" do
        xhr :get, :index, :q =>"languagelanguage"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__language_tesim')[0].should eql('languagelanguage')
      end
      it "should find a file by resource_type" do
        xhr :get, :index, :q =>"resource_typeresource_type"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__resource_type_tesim')[0].should eql('resource_typeresource_type')
      end
      it "should find a file by format_label" do
        xhr :get, :index, :q =>"format_labelformat_label"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'file_format_tesim')[0].should eql('format_labelformat_label')
      end
      it "should find a file by description" do
        xhr :get, :index, :q =>"descriptiondescription"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
        assigns(:document_list)[0].fetch(:'desc_metadata__description_tesim')[0].should eql('descriptiondescription')
      end
      it "should find a file by full_text" do
        xhr :get, :index, :q =>"full_textfull_text"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
      end
      it "should find a file by depositor" do
        xhr :get, :index, :q =>"mjg36"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(3)
      end
      it "should find a file by depositor in advanced search" do
        xhr :get, :index, :depositor =>"mjg36", :search_field => "advanced"
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(3)
      end
    end
    describe "facet search" do
      before do
        xhr :get, :index, :q=>"{f=desc_metadata__contributor_facet}Contrib2"
      end
      it "should find facet files" do
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
      end
    end
    describe "user with group search" do
      before do
        User.any_instance.stub(:groups).and_return(['umg/personal.testuser.testgroup'])
        xhr :get, :index, :q=>"{f=desc_metadata__contributor_facet}Contrib2"
      end
      it "should find facet files" do
        response.should be_success
        response.should render_template('catalog/index')
        assigns(:document_list).count.should eql(1)
      end
    end
  end

  describe "#recent" do
    before do
      @gf1 = GenericFile.new(title:'Generic File 1', contributor:'contributor 1', resource_type:'type 1', read_groups:['public'])
      @gf1.apply_depositor_metadata('mjg36')
      @gf1.save
      sleep 1 # make sure next file is not at the same time compare
      @gf2 = GenericFile.new(title:'Generic File 2', contributor:'contributor 2', resource_type:'type 2', read_groups:['public'])
      @gf2.apply_depositor_metadata('mjg36')
      @gf2.save
      sleep 1 # make sure next file is not at the same time compare
      @gf3 = GenericFile.new(title:'Generic File 3', contributor:'contributor 3', resource_type:'type 3', read_groups:['public'])
      @gf3.apply_depositor_metadata('mjg36')
      @gf3.save
      sleep 1 # make sure next file is not at the same time compare
      @gf4 = GenericFile.new(title:'Generic File 4', contributor:'contributor 4', resource_type:'type 4', read_groups:['public'])
      @gf4.apply_depositor_metadata('mjg36')
      @gf4.save
      xhr :get, :recent
    end

    after do
      @gf1.delete
      @gf2.delete
      @gf3.delete
      @gf4.delete
    end

    it "should find my 3 files" do
      response.should be_success
      response.should render_template('catalog/recent')
      assigns(:recent_documents).count.should eql(3)
      # the order is reversed since the first in should be the last out in descending time order
      lgf3 = assigns(:recent_documents)[0]
      lgf2 = assigns(:recent_documents)[1]
      lgf1 = assigns(:recent_documents)[2]
      descriptor = Solrizer::Descriptor.new(:text_en, :stored, :indexed, :multivalued)
      lgf3.fetch(Solrizer.solr_name('desc_metadata__title', descriptor))[0].should eql(@gf4.title[0])
      lgf3.fetch(Solrizer.solr_name('desc_metadata__contributor', descriptor))[0].should eql(@gf4.contributor[0])
      lgf3.fetch(Solrizer.solr_name('desc_metadata__resource_type', descriptor))[0].should eql(@gf4.resource_type[0])
      lgf1.fetch(Solrizer.solr_name('desc_metadata__title', descriptor))[0].should eql(@gf2.title[0])
      lgf1.fetch(Solrizer.solr_name('desc_metadata__contributor', descriptor))[0].should eql(@gf2.contributor[0])
      lgf1.fetch(Solrizer.solr_name('desc_metadata__resource_type', descriptor))[0].should eql(@gf2.resource_type[0])
    end
  end
end
