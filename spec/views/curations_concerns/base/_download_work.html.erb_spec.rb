# frozen_string_literal: true

require 'rails_helper'

describe 'curation_concerns/base/_download_work.html.erb' do
  let(:user)      { create(:user) }
  let(:ability)   { Ability.new(user) }
  let(:work)      { build(:work, id: '1', depositor: user.email) }
  let(:doc)       { SolrDocument.new(work.to_solr) }
  let(:presenter) { WorkShowPresenter.new(doc, ability, nil) }

  before do
    render 'curation_concerns/base/download_work', presenter: presenter
  end

  it 'displays a download button' do
    expect(rendered).to include("<a target=\"_blank\" data-turbolinks=\"false\" class=\"btn btn-default\" href=\"/downloads/#{work.id}\">\n      Download Work as Zip\n</a>")
  end
end
