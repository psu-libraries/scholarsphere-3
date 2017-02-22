# frozen_string_literal: true
require 'rails_helper'

describe TranslatedFacetAttributeRenderer do
  let(:field)   { :name }
  let(:mapping) { { "BOB" => "Bob", "JESSICA" => "Jessica" } }

  describe "#attribute_to_html" do
    subject { Nokogiri::HTML(renderer.render) }
    let(:expected) { Nokogiri::HTML(tr_content) }

    context "with explicit facet values" do
      let(:renderer) { described_class.new(field, ['BOB', 'JESSICA'], mapping: mapping) }

      let(:tr_content) {%(
        <tr><th>Name</th>
        <td><ul class='tabular'>
        <li class="attribute name"><a href="/catalog?f%5Bname_sim%5D%5B%5D=Bob">BOB</a></li>
        <li class="attribute name"><a href="/catalog?f%5Bname_sim%5D%5B%5D=Jessica">JESSICA</a></li>
        </ul></td></tr>
      )}

      it { expect(renderer).not_to be_microdata(field) }
      it { expect(subject).to be_equivalent_to(expected) }
    end

    context "without facet values" do
      let(:renderer) { described_class.new(field, ['BOB', 'JESSICA']) }

      let(:tr_content) {%(
        <tr><th>Name</th>
        <td><ul class='tabular'>
        <li class="attribute name"><a href="/catalog?f%5Bname_sim%5D%5B%5D=BOB">BOB</a></li>
        <li class="attribute name"><a href="/catalog?f%5Bname_sim%5D%5B%5D=JESSICA">JESSICA</a></li>
        </ul></td></tr>
      )}

      it { expect(renderer).not_to be_microdata(field) }
      it { expect(subject).to be_equivalent_to(expected) }
    end
  end
end
