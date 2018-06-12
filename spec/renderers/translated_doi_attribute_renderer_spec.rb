# frozen_string_literal: true

require 'rails_helper'

describe TranslatedDoiRenderer do
  let(:field) { :identifier }

  describe '#attribute_to_html' do
    subject { Nokogiri::HTML(renderer.render) }

    let(:expected) { Nokogiri::HTML(dl_content) }

    context 'with explicit facet values' do
      let(:renderer) { described_class.new(field, ['other id', 'doi:10.18113/S1V91R']) }

      let(:dl_content) { %(
<dt class="attribute-term">Identifier</dt>
<dd class="attribute identifier">other id</dd>
<dd class="attribute identifier"><a href="https://doi.org/10.18113/S1V91R"><span class="glyphicon glyphicon-new-window"></span> https://doi.org/10.18113/S1V91R</a></dd>
)}

      it { expect(renderer).not_to be_microdata(field) }
      it { expect(subject).to be_equivalent_to(expected) }
    end
  end
end
