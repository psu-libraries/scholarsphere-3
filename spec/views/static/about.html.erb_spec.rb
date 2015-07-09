require 'spec_helper'

describe 'pages/show.html.erb', type: :view do
  subject { rendered }

  before do
    allow(view).to receive(:can?).and_return(false)
    assign(:page, ContentBlock.new(name: "about", value: "What is ScholarSphere?"))
    render
  end

  it { is_expected.to match /What is ScholarSphere?/ }

end
