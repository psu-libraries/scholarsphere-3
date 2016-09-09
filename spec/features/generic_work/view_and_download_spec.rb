# frozen_string_literal: true
# This file is a Work in Progress
require 'feature_spec_helper'

include Selectors::Dashboard

describe GenericWork, type: :feature do
  context "when viewing as a standard user" do
    let(:current_user) { create(:user) }
    let!(:work1) do
      create(:public_work, :with_one_file, :with_complete_metadata,
             depositor: current_user.login,
             description: ["Description http://example.org/TheDescriptionLink/"]
            )
    end
    let!(:work2) { create(:private_work, depositor: current_user.login) }

    before do
      sign_in_with_js(current_user)
      visit(main_app.polymorphic_path(work1))
    end

    context 'When viewing a file' do
      specify "I see all the correct information" do
        expect(page).to have_content work1.title.first
        expect(page).not_to have_link "Feature"
        within("h1 span") do
          expect(page).to have_content("Open Access")
        end

        within("ul.breadcrumb") do
          expect(page).to have_link("My Dashboard")
          # TODO: sufia does not contain the works breadcrumb
          # expect(page).to have_link("My Works")
        end

        expect(page).to have_link 'http://example.org/TheDescriptionLink/'
        expect(page).to have_link work1.related_url.first
        expect(page).to have_link work1.creator.first
        expect(page).to have_link work1.contributor.first
        expect(page).to have_link work1.keyword.first
        expect(page).to have_link work1.subject.first
        expect(page).to have_link work1.publisher.first
        expect(page).to have_link work1.language.first
        expect(page).to have_link work1.based_near.first
        expect(page).to have_link work1.resource_type.first
        expect(page).to have_link work1.related_url.first
        expect(page).to have_link("Attribution 3.0 United States")

        # TODO: loop through all links to visit and check them
        # test_links.each do |name, link|
        #   test_link name, link
        # end

        # test the EndNote page
        visit(find_link('EndNote')[:href])
        expect(page.response_headers['Content-Type']).to eq('application/x-endnote-refer')
      end

      # specify 'I can see the Mendeley modal' do
      #  skip 'This does not appear to be functioning properly'
      #  click_link 'Mendeley'
      #  expect(page).to have_css('.modal-header')
      # end
      #
      # specify 'I can see the Zotero modal' do
      #  skip 'This does not appear to be functioning properly'
      #  click_link 'Zotero'
      #  expect(page).to have_css('.modal-header')
      # end
    end
  end

  context "administrator user" do
    let(:admin_user)    { create(:administrator) }
    let!(:public_file)  { create(:public_file, depositor: admin_user.login) }
    let!(:private_file) { create(:private_file, depositor: admin_user.login) }

    before do
      sign_in_with_js(admin_user)
      visit '/dashboard/works'
    end

    context 'When viewing a public file' do
      before  { db_item_title(public_file).click }
      specify { expect(page).to have_link "Feature" }
    end

    context 'When viewing a private file' do
      before  { db_item_title(private_file).click }
      specify { expect(page).not_to have_link "Feature" }
    end
  end

  context 'When downloading a file' do
    # TBD
  end

  def store_link(link_name, test_links)
    expect(page).to have_link link_name
    test_links[link_name] = find_link(link_name)[:href]
    test_links
  end

  def test_link(_link_name, link_value)
    visit link_value
    expect(page).to have_content work1.title.first
    expect(page).not_to have_content work1.title.first
  end
end
