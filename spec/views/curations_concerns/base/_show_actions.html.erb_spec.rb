# frozen_string_literal: true

require 'rails_helper'

describe 'curation_concerns/base/_show_actions.html.erb' do
  let(:user)      { create(:user) }
  let(:ability)   { Ability.new(user) }
  let(:work)      { build(:work, id: '1', depositor: user.email) }
  let(:doc)       { SolrDocument.new(work.to_solr) }
  let(:presenter) { WorkShowPresenter.new(doc, ability, nil) }

  context 'when files are being uploaded' do
    before do
      allow(presenter).to receive(:uploading?).and_return(true)
      render 'curation_concerns/base/show_actions', presenter: presenter
    end

    it 'displays disabled buttons' do
      expect(rendered).to include('<button type="button" class="btn btn-default" disabled="disabled">Edit</button>')
      expect(rendered).to include('<button type="button" class="btn btn-danger" disabled="disabled">Delete</button>')
    end
  end
end
