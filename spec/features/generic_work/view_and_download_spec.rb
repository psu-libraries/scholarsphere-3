# frozen_string_literal: true
require 'feature_spec_helper'

include Selectors::Dashboard

describe GenericWork, type: :feature do
  context "as a standard user" do
    let(:current_user) { create(:user) }

    before { sign_in_with_js(current_user) }

    context "with a public work" do
      let!(:work1) do
        create(:public_work, :with_one_file_and_size, :with_complete_metadata,
               depositor: current_user.login,
               description: ["Description http://example.org/TheDescriptionLink/"]
              )
      end

      specify "I can see all the correct information" do
        visit(root_path)

        # Work is listed under Recently Uploaded
        click_link("Recent Additions")
        within("#recent_docs") do
          expect(page).to have_link(work1.keyword.first)
          click_link(work1.title.first)
        end

        # View the work's show page
        expect(page).to have_content work1.title.first
        expect(page).not_to have_link "Feature"
        within("h1 span") do
          expect(page).to have_content("Open Access")
        end

        within("ul.breadcrumb") do
          expect(page).to have_link("My Dashboard")
          expect(page).to have_link("My Works")
        end

        within("p.work_description") do
          expect(page).to have_link 'http://example.org/TheDescriptionLink/'
        end

        within("dl.generic_work") do
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
          expect(page).to have_content("1 Byte")
          within("dd.total_items") do
            expect(page).to have_content("1")
          end
          expect(page).to have_content("Published Date")
        end
      end

      describe "external services" do
        before { visit(curation_concerns_generic_work_path(work1)) }

        specify "I can download an Endnote reference" do
          visit(find_link('EndNote')[:href])
          expect(page.response_headers['Content-Type']).to eq('application/x-endnote-refer')
        end

        specify 'I can see the Mendeley modal' do
          click_link 'Mendeley'
          expect(page).to have_css('.modal-header')
        end

        specify 'I can see the Zotero modal' do
          click_link 'Zotero'
          expect(page).to have_css('.modal-header')
        end
      end
    end

    context "with a registered work" do
      let(:registered_user)  { create(:user) }
      let!(:registered_work) { create(:registered_work, title: ["Reg. work"], depositor: registered_user.login) }

      specify "I can see all the correct information" do
        visit(root_path)

        # Work is listed under Recently Uploaded
        click_link("Recent Additions")
        within("#recent_docs") do
          expect(page).to have_link(registered_work.keyword.first)
          click_link(registered_work.title.first)
        end

        # View the work's show page
        expect(page).to have_content registered_work.title.first
        expect(page).not_to have_link "Feature"
        within("h1 span") do
          expect(page).to have_content("Penn State")
        end
      end
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
end
