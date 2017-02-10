# frozen_string_literal: true
require 'rails_helper'

describe CollectionIndexer do
  describe "fontawesome default icon" do
    let(:collection) { build(:collection, id: "1234") }
    let(:solr_doc) { described_class.new(collection).generate_solr_document }

    it "indexes thumbnail" do
      expect(solr_doc["thumbnail_path_ss"]).to start_with("/assets/collection")
    end
  end
end
