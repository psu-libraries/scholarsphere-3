require 'spec_helper'

describe "catalog/_index_default.html.erb" do
  let(:document) { SolrDocument.new(id: '123', 'title_tesim' => 'Foo',
                                    'description_tesim' => 'The description') }

  let(:config) { CatalogController.blacklight_config }

  before do
    allow(view).to receive(:blacklight_config).and_return(config)
    allow(view).to receive(:document).and_return(document)
    params[:view] = view_type
    render
  end

  context "list view" do
    let(:view_type) { 'list' }

    it "only displays fields listed in the initializer" do
      expect(rendered).to have_content("Foo")
      expect(rendered).to have_content("The description")
    end
  end

  context "gallery view" do
    let(:view_type) { 'gallery' }

    it "only displays fields listed in the initializer" do
      expect(rendered).not_to have_content("Foo")
      expect(rendered).not_to have_content("The description")
    end
  end
end
