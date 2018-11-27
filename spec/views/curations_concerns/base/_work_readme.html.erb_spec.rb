# frozen_string_literal: true

require 'rails_helper'

describe 'curation_concerns/base/_work_readme.html.erb' do
  let(:user)      { create(:user) }
  let(:ability)   { Ability.new(user) }
  let(:work)      { build(:work, id: '1', depositor: user.email, resource_type: ['Book']) }
  let(:doc)       { SolrDocument.new(work.to_solr) }
  let(:presenter) { WorkShowPresenter.new(doc, ability, nil) }

  before do
    render 'curation_concerns/base/work_readme', presenter: presenter
  end

  it 'does not display a README prompt' do
    expect(rendered).not_to include('How about adding a README file?')
  end

  context 'audio file' do
    let(:work) { build(:work, id: '1', depositor: user.email, resource_type: ['Audio']) }

    it 'displays a README prompt' do
      expect(rendered).to include('How about adding a README file?')
    end
  end

  context 'work with a readme' do
    let(:doc) { SolrDocument.new(work.to_solr.merge("readme_file_ss": 'This is a readme for testing.')) }

    it 'displays a README contents' do
      expect(rendered).to include('This is a readme for testing.')
    end
  end
end
