# frozen_string_literal: true
require 'spec_helper'

describe SolrDocument do
  let(:work) { build(:work, id: "foo") }
  subject { described_class.new(work.to_solr) }

  describe "#export_as_endnote" do
    let(:export) do
      "%0 Work\n" \
      "%T Sample Title\n" \
      "%R http://scholarsphere.psu.edu/files/#{work.id}\n" \
      "%~ ScholarSphere\n" \
      "%W Penn State University"
    end
    its(:export_as_endnote) { is_expected.to eq(export) }
  end
end
