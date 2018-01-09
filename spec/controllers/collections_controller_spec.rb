# frozen_string_literal: true

require 'rails_helper'

describe CollectionsController, type: :controller do
  subject { response }

  context "when the Collection doesn't exist" do
    before { get :show, id: 'non-existent-collection' }
    its(:status) { is_expected.to eq(302) }
  end

  context 'when requesting a legacy URL' do
    before { get :show, id: 'scholarsphere:123' }
    its(:status) { is_expected.to eq(301) }
    its(:location) { is_expected.to eq('http://test.host/collections/123') }
  end

  context 'when requesting an existing collection' do
    let(:work1)       { create(:public_work) }
    let(:work2)       { create(:public_work) }
    let!(:collection) { create(:public_collection, members: [work1, work2]) }

    before { get :show, id: collection.id, per_page: 1, page: 2 }
    it { is_expected.to be_success }
  end

  context 'when editing an existing collection' do
    let(:user) { create(:user) }
    let(:work1)       { create(:public_work, depositor: user.login) }
    let(:work2)       { create(:public_work, depositor: user.login) }
    let!(:collection) { create(:public_collection, members: [work1, work2], depositor: user.login) }

    before do
      allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
    end
    it 'runs the migration' do
      expect(Migration::SolrListMigrator).to receive(:update).and_call_original
      get :edit, id: collection.id
      expect(response).to be_success
    end
  end

  describe '::form_class' do
    subject { described_class }

    its(:form_class) { is_expected.to be(CollectionForm) }
  end

  describe '#delete' do
    let(:user) { create(:user) }
    let(:collection) { create(:collection, depositor: user.login) }

    before do
      allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end

    context 'when the collection is successfully deleted' do
      before { delete :destroy, id: collection }
      it { is_expected.to redirect_to('/dashboard/collections') }
    end

    context 'when the collection is not successfully deleted' do
      before do
        controller.instance_variable_set(:@collection, collection)
        allow(collection).to receive(:destroy).and_return(false)
        delete :destroy, id: collection
      end
      it { is_expected.to redirect_to('/dashboard/collections') }
    end

    describe '#create' do
      let(:collection) { assigns[:collection] }
      let(:permissions) { collection.permissions.map(&:to_hash) }

      let(:user) { create(:user) }

      before do
        allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
        allow_any_instance_of(User).to receive(:groups).and_return([])
        post :create, collection: { 'title' => 'Test', 'subtitle' => '', 'creators' => { '0' => { 'id' => '', 'given_name' => 'Lorraine C', 'sur_name' => 'Santy', 'display_name' => 'Lorraine C Santy', 'email' => '', 'psu_id' => '' } }, 'description' => ['Test Description'], 'keyword' => ['test'], 'contributor' => [''], 'rights' => '', 'publisher' => [''], 'date_created' => [''], 'subject' => [''], 'language' => [''], 'identifier' => [''], 'based_near' => [''], 'related_url' => [''], 'resource_type' => [''], 'visibility' => 'open', 'permissions_attributes' => { '0' => { 'type' => 'group', 'name' => 'umg/course.1479EEE5-988A-3A80-6BF2-45421CAAB5C3', 'access' => 'edit' } } }
      end

      it 'applies the persmissions' do
        collection.reload # doing a reload to make sure the permissions made it all the way to fedora
        expect(permissions).to contain_exactly({ name: 'public', type: 'group', access: 'read' }, { name: user.login, type: 'person', access: 'edit' }, name: 'umg/course.1479EEE5-988A-3A80-6BF2-45421CAAB5C3', type: 'group', access: 'edit')
      end
    end
  end
end
