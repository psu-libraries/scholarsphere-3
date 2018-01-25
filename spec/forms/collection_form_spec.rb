# frozen_string_literal: true

require 'rails_helper'

describe CollectionForm do
  let(:ability)    { Ability.new(nil) }
  let(:collection) { build(:collection, id: 'collection-id') }
  let(:form)       { described_class.new(collection, ability, nil) }
  let(:work)       { create(:work) }

  before { allow(form).to receive(:batch_document_ids).and_return([work.id]) }

  describe '#incorporated_work_presenters' do
    subject { form.incorporated_work_presenters }

    it { is_expected.to contain_exactly(kind_of(WorkShowPresenter)) }
  end

  describe '#incorporated_member_docs' do
    subject { form.incorporated_member_docs }

    it { is_expected.to contain_exactly(kind_of(SolrDocument)) }
  end

  describe '#primary_terms' do
    subject { form.primary_terms }

    it { is_expected.to contain_exactly(:title, :subtitle, :creator, :description, :keyword) }
  end

  describe '#secondary_terms' do
    subject { form.secondary_terms }

    it { is_expected.to contain_exactly(:contributor,
                                        :rights,
                                        :publisher,
                                        :date_created,
                                        :subject,
                                        :language,
                                        :identifier,
                                        :based_near,
                                        :related_url,
                                        :resource_type) }
  end

  describe '::required_fields' do
    subject { described_class.required_fields }

    it { is_expected.to contain_exactly(:title, :description, :keyword) }
  end

  describe '#depositor' do
    subject { form.depositor }

    it { is_expected.to eq(collection.depositor) }
  end

  describe '#permissions' do
    subject { form.permissions.to_a }

    it { is_expected.to eq(collection.permissions.to_a) }
  end
end
