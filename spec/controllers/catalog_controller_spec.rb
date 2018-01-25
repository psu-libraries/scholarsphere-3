# frozen_string_literal: true

require 'rails_helper'

describe CatalogController, type: :controller do
  include FactoryHelpers

  let!(:file_set) { build(:file_set, id: 'fs') }
  let!(:work1)    { build(:public_work, :with_pdf, title: ['Test Document PDF'], id: '1') }
  let!(:work2)    { build(:public_work, title: ['Test 2 Document'], contributor: ['Contrib2'], id: '2') }
  let!(:work3)    { build(:public_work, :with_complete_metadata, id: '3', members: [file_set]) }

  let(:text) { mock_file_factory(content: 'full_textfull_text') }
  let(:file) { mock_file_factory(format_label: ['format_labelformat_label']) }

  before do
    allow_any_instance_of(User).to receive(:groups).and_return([])
    allow(file_set).to receive(:extracted_text).and_return(text)
    allow(text).to receive(:force_encoding).and_return(text)
    allow(file_set).to receive(:original_file).and_return(file)
    allow(work3).to receive(:representative).and_return(file_set)
  end

  # Default depositor if none is supplied
  let(:user) { 'user' }

  describe 'config' do
    describe 'index_fields' do
      subject { described_class.blacklight_config.index_fields.keys }

      it { is_expected.to contain_exactly('based_near_tesim',
                                          'date_uploaded_dtsi',
                                          'keyword_tesim',
                                          'language_tesim',
                                          'publisher_tesim',
                                          'resource_type_tesim',
                                          'subject_tesim',
                                          'has_model_ssim',
                                          'creator_name_tesim')
      }
    end
    describe 'show_fields' do
      subject { described_class.blacklight_config.show_fields.keys }

      it { is_expected.to contain_exactly('depositor_tesim', 'based_near_tesim', 'date_modified_dtsi', 'date_uploaded_dtsi',
                                          'description_tesim', 'identifier_tesim', 'keyword_tesim',
                                          'language_tesim', 'publisher_tesim', 'resource_type_tesim', 'rights_tesim',
                                          'subject_tesim', 'contributor_tesim', 'creator_name_tesim', 'date_created_tesim',
                                          'subtitle_tesim')
      }
    end
    describe 'facet_fields' do
      subject { described_class.blacklight_config.facet_fields.keys }

      it { is_expected.to contain_exactly('based_near_sim', 'collection_sim', 'has_model_ssim',
                                          'file_format_sim', 'keyword_sim',
                                          'language_sim', 'publisher_sim', 'resource_type_sim',
                                          'subject_sim', 'creator_name_sim')
      }
    end
  end

  describe '#index' do
    before do
      ActiveFedora::Cleaner.cleanout_solr
      index_file_set(file_set)
      index_work(work1)
      index_work(work2)
      index_work(work3)
    end
    describe 'term search' do
      it 'finds pdf files' do
        xhr :get, :index, q: 'pdf'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('title'))[0]).to eql('Test Document PDF')
      end
      it 'finds a file by title' do
        xhr :get, :index, q: 'titletitle'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('title'))[0]).to eql('titletitle')
      end
      it 'finds a file by keyword' do
        xhr :get, :index, q: 'tagtag'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('keyword'))[0]).to eql('tagtag')
      end
      it 'finds a file by subject' do
        xhr :get, :index, q: 'subjectsubject'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('subject'))[0]).to eql('subjectsubject')
      end
      it 'finds a file by creator' do
        xhr :get, :index, q: 'creatorcreator'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('creator_name'))[0]).to eql('creatorcreator')
      end
      it 'finds a file by contributor' do
        xhr :get, :index, q: 'contributorcontributor'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('contributor'))[0]).to eql('contributorcontributor')
      end
      it 'finds a file by publisher' do
        xhr :get, :index, q: 'publisherpublisher'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('publisher'))[0]).to eql('publisherpublisher')
      end
      it 'finds a file by based_near' do
        xhr :get, :index, q: 'based_nearbased_near'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('based_near'))[0]).to eql('based_nearbased_near')
      end
      it 'finds a file by language' do
        xhr :get, :index, q: 'languagelanguage'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('language'))[0]).to eql('languagelanguage')
      end
      it 'finds a file by resource_type' do
        xhr :get, :index, q: 'resource_typeresource_type'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('resource_type'))[0]).to eql('resource_typeresource_type')
      end
      it 'finds a file by format_label' do
        xhr :get, :index, q: 'format_labelformat_label'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('file_format'))[0]).to eql('plain (format_labelformat_label)')
      end
      it 'finds a file by description' do
        xhr :get, :index, q: 'descriptiondescription'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('description'))[0]).to eql('descriptiondescription')
      end
      it 'finds a file by full_text' do
        xhr :get, :index, q: 'full_textfull_text'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
      end
      it 'finds a file by depositor' do
        xhr :get, :index, q: user
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(3)
      end
      it 'finds a file by depositor in advanced search' do
        xhr :get, :index, depositor: user, search_field: 'advanced'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(3)
      end
    end
    describe 'facet search' do
      before do
        xhr :get, :index, q: "{f=#{contributor_facet}}Contrib2"
      end
      it 'finds facet files' do
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
      end
    end
    describe 'user with group search' do
      before do
        allow_any_instance_of(User).to receive(:groups).and_return(['umg/personal.testuser.testgroup'])
        xhr :get, :index, q: "{f=#{contributor_facet}}Contrib2"
      end
      it 'finds facet files' do
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
      end
    end
  end
end
