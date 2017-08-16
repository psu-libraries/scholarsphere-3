# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Static pages' do
  it 'displays the About page' do
    visit('/about')
    expect(page).to have_content('About')
  end

  it 'displays the Help page' do
    visit('/help')
    expect(page).to have_content('Frequently Asked Questions')
    expect(page).to have_content('User Support')
    expect(page).to have_content('Support Hours')
    expect(page).to have_link('Contact Form')
    expect(page).to have_link('Publishing and Curation Services')
    expect(page).to have_link('University Libraries')
  end

  it 'displays the Zotero page' do
    visit('/zotero')
    expect(page).to have_content('Export to Zotero')
  end

  it 'displays the Mendeley page' do
    visit('/mendeley')
    expect(page).to have_content('Export to Mendeley')
  end

  it 'displays the Licenses page' do
    visit('/licenses')
    expect(page).to have_content('ScholarSphere License Descriptions')
  end

  it 'displays the Versions page' do
    visit('/versions')
    expect(page).to have_content('Versions')
  end

  it 'displays the Terms of Use page' do
    visit('/terms')
    expect(page).to have_content('Terms of Use for ScholarSphere')
  end
end
