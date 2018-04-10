# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'my/_part_of_collection.html.erb', type: :view do
  let(:collection1) { build :collection, title: ['Collection Uno'], id: '123' }
  let(:collection2) { build :collection, title: ['Collection Dos'], id: '133' }

  before do
    render 'my/part_of_collection', collection_presenters: collection_presenters
  end

  context 'when the work is a part of collections' do
    let(:collection_presenters) { [CollectionPresenter.new(collection1, nil),
                                   CollectionPresenter.new(collection2, nil)] }

    it 'displays the list of collections the work is a part of' do
      expect(rendered).to have_selector('ul')
      expect(rendered).to have_selector('li', text: 'Collection Uno')
      expect(rendered).to have_selector('li', text: 'Collection Dos')
    end
  end

  context 'when the work is not part of any collections' do
    let(:collection_presenters) { nil }

    it 'does not display the list' do
      expect(rendered).to eq ''
    end
  end
end
