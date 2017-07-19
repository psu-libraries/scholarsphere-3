# frozen_string_literal: true
require 'feature_spec_helper'

describe GenericWork do
  let(:current_user) { create(:user) }

  context "without files" do
    let(:work) do
      build(:public_work, :with_complete_metadata, id: "public-work", depositor: current_user.login)
    end

    let(:thumbnail_source) { page.find(".canonical-image")["src"] }

    before do
      index_work(work)
      visit("/concern/generic_works/public-work")
    end

    it "displays properly" do
      expect(page).to have_content(work.title.first)
      expect(thumbnail_source).to match(/nope/)
      sign_in(current_user)
      go_to_dashboard_works
      within("#document_public-work") do
        expect(page).to have_css("img[aria-hidden='true']")
        expect(page).to have_css("img[alt='']")
      end
    end
  end

  context "with files" do
    let(:public_file_set) do
      build(:file_set, :with_file_size, :public,
            id: "public-fileset",
            title: ["Public File"],
            user: current_user)
    end

    let(:registered_file_set) do
      build(:file_set, :with_file_size, :registered,
            id: "registered-fileset",
            title: ["Registered File"],
            user: current_user)
    end

    let(:list_source) do
      HashWithIndifferentAccess.new(ActiveFedora::Aggregation::ListSource.new.to_solr)
                               .merge(id: "#{work.id}/list_source")
                               .merge(proxy_in_ssi: work.id.to_s)
                               .merge(ordered_targets_ssim: file_sets.map(&:id))
    end

    let(:thumbnail_source) { page.find(".representative-media")["src"] }

    before do
      file_sets.each { |fs| index_file_set(fs) }
      index_document(list_source)
      index_work(work)
      visit("/concern/generic_works/public-work")
    end

    context "using a public file as representative" do
      let(:file_sets) { [public_file_set] }
      let(:work) do
        build(:public_work, :with_complete_metadata,
              id: "public-work",
              depositor: current_user.login,
              representative_id: "public-fileset",
              members: file_sets)
      end

      it "displays properly" do
        expect(page).to have_content(work.title.first)
        expect(page).to have_link("Download file")
        expect(thumbnail_source).to eq(CurationConcerns::ThumbnailPathService.send(:default_image))
        sign_in(current_user)
        go_to_dashboard_works
        within("#document_public-work") do
          expect(page).to have_css("img[aria-hidden='true']")
          expect(page).to have_css("img[alt='']")
        end
      end
    end

    context "using a registered file as representative" do
      let(:file_sets) { [registered_file_set] }
      let(:work) do
        build(:public_work, :with_complete_metadata,
              id: "public-work",
              depositor: current_user.login,
              representative_id: "registered-fileset",
              members: file_sets)
      end

      it "displays properly" do
        expect(page).to have_content(work.title.first)
        expect(page).not_to have_link("Download file")
        expect(thumbnail_source).to eq(CurationConcerns::ThumbnailPathService.send(:default_image))
        sign_in(current_user)
        go_to_dashboard_works
        within("#document_public-work") do
          expect(page).to have_css("img[aria-hidden='true']")
          expect(page).to have_css("img[alt='']")
        end
      end
    end

    context "having a public file and a registered file, with the registered file as representative" do
      let(:file_sets) { [registered_file_set, public_file_set] }
      let(:work) do
        build(:public_work, :with_complete_metadata,
              id: "public-work",
              depositor: current_user.login,
              representative_id: "registered-fileset",
              members: file_sets)
      end

      it "displays properly" do
        expect(page).to have_content(work.title.first)
        expect(page).not_to have_link("Download file")
        expect(thumbnail_source).to eq(CurationConcerns::ThumbnailPathService.send(:default_image))
        sign_in(current_user)
        go_to_dashboard_works
        within("#document_public-work") do
          expect(page).to have_css("img[aria-hidden='true']")
          expect(page).to have_css("img[alt='']")
        end
      end
    end
  end

  context "with a public work and a restricted thumbnail" do
    let(:work) do
      build(:public_work, :with_complete_metadata,
            id: "public-work",
            title: ["Restricted thumbnail"],
            depositor: current_user.login)
    end

    before do
      doc = work.to_solr
      doc["thumbnail_path_ss"] = "/downloads/restricted-id?file=thumbnail"
      index_document(doc)
      sign_in_with_named_js(:thumbnail)
      visit(root_path)
    end

    it "displays the default work image for the thumbnail" do
      within('#search-form-header') do
        fill_in('search-field-header', with: work.title.first)
        click_button("Go")
      end
      within("#document_public-work") do
        expect(page.find("img")["src"]).to end_with(ActionController::Base.helpers.image_path("work.png"))
      end
    end
  end
end
