# frozen_string_literal: true
require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  let(:user)     { create(:user) }
  let(:admin)    { create(:administrator) }
  let(:work)     { build(:work, id: '1234') }
  let(:solr_doc) { SolrDocument.new(work.to_solr) }

  context "with a typical user" do
    subject { described_class.new(user) }
    it { is_expected.not_to be_able_to(:read, solr_doc) }
  end

  context "with an admin" do
    subject { described_class.new(admin) }
    it { is_expected.to be_able_to(:read, solr_doc) }
  end
end
