# frozen_string_literal: true
require 'rails_helper'

describe CollectionForm do
  let(:ability)    { Ability.new(nil) }
  let(:collection) { build(:collection, id: "collection-id") }
  let(:form)       { described_class.new(collection, ability, nil) }
  let(:work)       { create(:work) }

  before { allow(form).to receive(:batch_document_ids).and_return([work.id]) }

  describe "#incorporated_work_presenters" do
    subject { form.incorporated_work_presenters }
    it { is_expected.to contain_exactly(kind_of(WorkShowPresenter)) }
  end

  describe "#incorporated_member_docs" do
    subject { form.incorporated_member_docs }
    it { is_expected.to contain_exactly(kind_of(SolrDocument)) }
  end
end
