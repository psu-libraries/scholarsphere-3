# frozen_string_literal: true

require 'rails_helper'

describe CatalogController, type: :controller do
  include FactoryHelpers

  describe 'config' do
    describe 'index_fields' do
      subject { described_class.blacklight_config.index_fields.keys }

      it { expect(subject).to contain_exactly('based_near_tesim',
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

      it { expect(subject).to contain_exactly('depositor_tesim', 'based_near_tesim', 'date_modified_dtsi', 'date_uploaded_dtsi',
                                          'description_tesim', 'identifier_tesim', 'keyword_tesim',
                                          'language_tesim', 'publisher_tesim', 'resource_type_tesim', 'rights_tesim',
                                          'subject_tesim', 'contributor_tesim', 'creator_name_tesim', 'date_created_tesim',
                                          'subtitle_tesim')
      }
    end

    describe 'facet_fields' do
      subject { described_class.blacklight_config.facet_fields.keys }

      it { expect(subject).to contain_exactly('based_near_sim', 'collection_sim', 'has_model_ssim',
                                          'file_format_sim', 'keyword_sim',
                                          'language_sim', 'publisher_sim', 'resource_type_sim',
                                          'subject_sim', 'creator_name_sim')
      }
    end
  end

  describe '#index' do
    let(:file_set) { build(:file_set, id: 'fs') }
    let(:creator1) { create(:creator, display_name: 'Sam') }
    let(:creator2) { create(:alias, display_name: 'Gus', agent: creator1.agent) }
    let(:creator3) { create(:alias, display_name: 'Bob', agent: creator1.agent) }
    let(:work1)    { build(:public_work, title: ['Test 1 Document'], id: '1', creators: [creator1]) }
    let(:work2)    { build(:public_work, title: ['Test 2 Document'], contributor: ['Contrib2'], id: '2', creators: [creator2]) }
    let(:work3)    { build(:public_work, :with_complete_metadata, id: '3', members: [file_set], creators: [creator3]) }
    let(:work4)    { build(:public_work, title: ['TAXgg_Xerumbrepts_100m.tif'], id: '4') }
    let(:user)     { 'user' }
    let(:file)     { mock_file_factory(format_label: ['format_labelformat_label'], mime_type: 'application/pdf') }

    # Create a list source record that links the file set to the work
    let(:list_source) do
      HashWithIndifferentAccess.new(ActiveFedora::Aggregation::ListSource.new.to_solr)
        .merge(id: "#{work1.id}/list_source")
        .merge(proxy_in_ssi: work3.id.to_s)
        .merge(ordered_targets_ssim: [file_set.id])
    end

    before do
      ActiveFedora::Cleaner.cleanout_solr
      allow_any_instance_of(User).to receive(:groups).and_return([])
      allow(file_set).to receive(:original_file).and_return(file)
      allow(work3).to receive(:representative).and_return(file_set)
      index_document(file_set.to_solr.merge('all_text_timv' => 'the quick brown fox jumped over the lazy dog.'))
      index_document(list_source)
      index_work(work1)
      index_work(work2)
      index_work(work3)
      index_work(work4)
    end

    describe 'term search' do
      it 'finds pdf files' do
        get :index, params: { q: 'pdf' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('title'))[0]).to eql('titletitle')
      end
      it 'finds a file by title' do
        get :index, params: { q: 'titletitle' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('title'))[0]).to eql('titletitle')
      end
      it 'finds a file by partial title' do
        get :index, params: { q: 'xerumbrepts' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('title'))[0]).to eql('TAXgg_Xerumbrepts_100m.tif')
      end
      it 'finds a file by keyword' do
        get :index, params: { q: 'tagtag' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('keyword'))[0]).to eql('tagtag')
      end
      it 'finds a file by subject' do
        get :index, params: { q: 'subjectsubject' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('subject'))[0]).to eql('subjectsubject')
      end
      it 'finds a file by creator' do
        get :index, params: { q: 'gus' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('creator_name'))[0]).to eql('Gus')
      end
      it 'finds a file by contributor' do
        get :index, params: { q: 'contributorcontributor' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('contributor'))[0]).to eql('contributorcontributor')
      end
      it 'finds a file by publisher' do
        get :index, params: { q: 'publisherpublisher' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('publisher'))[0]).to eql('publisherpublisher')
      end
      it 'finds a file by based_near' do
        get :index, params: { q: 'based_nearbased_near' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('based_near'))[0]).to eql('based_nearbased_near')
      end
      it 'finds a file by language' do
        get :index, params: { q: 'languagelanguage' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('language'))[0]).to eql('languagelanguage')
      end
      it 'finds a file by resource_type' do
        get :index, params: { q: 'resource_typeresource_type' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('resource_type'))[0]).to eql('resource_typeresource_type')
      end
      it 'finds a file by format_label' do
        get :index, params: { q: 'format_labelformat_label' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('file_format'))[0]).to eql('pdf (format_labelformat_label)')
      end
      it 'finds a file by description' do
        get :index, params: { q: 'descriptiondescription' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('description'))[0]).to eql('descriptiondescription')
      end
      it 'finds a file by full_text' do
        get :index, params: { q: 'brown fox', search_field: 'all_fields' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
        expect(assigns(:document_list)[0].fetch(solr_field('title'))[0]).to eql('titletitle')
      end
      it 'finds a file by depositor' do
        get :index, params: { q: user }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(4)
      end
      it 'finds a file by depositor in advanced search' do
        get :index, params: { depositor: user, search_field: 'advanced' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(4)
      end
      it 'finds a file by creator in advanced search' do
        get :index, params: { q: creator1.agent.sur_name, search_field: 'all_fields' }
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(3)
      end
    end

    describe 'facet search' do
      before do
        get :index, params: { q: "{f=#{contributor_facet}}Contrib2" }
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
        get :index, params: { q: "{f=#{contributor_facet}}Contrib2" }
      end

      it 'finds facet files' do
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to be(1)
      end
    end
  end
end
