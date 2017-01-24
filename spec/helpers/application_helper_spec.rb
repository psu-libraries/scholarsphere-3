# frozen_string_literal: true
require 'rails_helper'

describe ApplicationHelper do
  describe "#more_facets_link_path" do
    context "with the shares controller" do
      before { allow(helper).to receive(:controller_name).and_return("shares") }

      it "returns the path" do
        expect(helper.more_facets_link_path("solr_field")).to eq("/dashboard/shares/facet/solr_field")
      end
    end

    context "with the works controller" do
      before { allow(helper).to receive(:controller_name).and_return("works") }

      it "returns the path" do
        expect(helper.more_facets_link_path("solr_field")).to eq("/dashboard/works/facet/solr_field")
      end
    end
  end
end
