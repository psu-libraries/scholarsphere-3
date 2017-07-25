# frozen_string_literal: true
require 'feature_spec_helper'

describe 'Catalog facets' do
  let(:work1) { build(:public_work, id: '1',
                                    contributor: ['Contri B. Utor'],
                                    publisher: ['Pu B. Lisher'],
                                    keyword: ['Key. Word.'],
                                    creator: ['Patricia M. Hswe']) }
  let(:work2) { build(:public_work, id: '2',
                                    contributor: ['CONTRI B. UTOR'],
                                    publisher: ['PU B. LISHER'],
                                    keyword: ['KEY. WORD.'],
                                    creator: ['PATRICIA M. HSWE']) }
  let(:work3) { build(:public_work, id: '3',
                                    contributor: ['Contri B Utor'],
                                    publisher: ['Pu B Lisher'],
                                    keyword: ['Key Word'],
                                    creator: ['Patricia M Hswe']) }

  before do
    index_works_and_collections(work1, work2, work3)
    visit '/catalog'
    click_link('Creator')
  end

  it 'displays case and punctuation-corrected facets' do
    within('div#facet-creator_sim') do
      expect(page).not_to have_content('Patricia M. Hswe')
      expect(page).to have_content('Patricia M Hswe')
      expect(page).to have_selector('span.facet-count', text: '(3)')
    end

    # Pending: #659
    # within("div#facet-contributor_sim") do
    #   expect(page).not_to have_content("Contri B. Utor")
    #   expect(page).to have_content("Contri B Utor")
    #   expect(page).to have_selector("span.facet-count", text: "(3)")
    # end

    within('div#facet-publisher_sim') do
      expect(page).not_to have_content('Pu B. Lisher')
      expect(page).to have_content('Pu B Lisher')
      expect(page).to have_selector('span.facet-count', text: '(3)')
    end
    within('div#facet-keyword_sim') do
      expect(page).not_to have_content('Key. Word.')
      expect(page).to have_content('key word')
      expect(page).to have_selector('span.facet-count', text: '(3)')
    end

    visit("/concern/generic_works/#{work2.id}")

    click_link('PATRICIA M. HSWE')
    within('div#search-results') do
      expect(page).to have_content('Patricia M. Hswe')
      expect(page).to have_content('Patricia M Hswe')
      expect(page).to have_content('PATRICIA M. HSWE')
    end

    visit("/concern/generic_works/#{work2.id}")
    click_link('PU B. LISHER')
    within('div#search-results') do
      expect(page).to have_content('Pu B. Lisher')
      expect(page).to have_content('Pu B Lisher')
      expect(page).to have_content('PU B. LISHER')
    end

    visit("/concern/generic_works/#{work2.id}")
    click_link('KEY. WORD.')
    within('div#search-results') do
      expect(page).to have_content('Key Word')
      expect(page).to have_content('Key. Word.')
      expect(page).to have_content('KEY. WORD.')
    end

    # Pending: #659?
    # visit("/concern/generic_works/#{work2.id}")
    # click_link("CONTRI B. UTOR")
    # within("div#search-results") do
    #   expect(page).to have_content("Contri B Utor")
    #   expect(page).to have_content("Contri B. Utor")
    #   expect(page).to have_content("CONTRI B. UTOR")
    # end
  end
end
