# frozen_string_literal: true
require 'feature_spec_helper'

# Notice that GenericWorks pick their thumbnail from the FileSets
# that belong to the work via the work.thumbnail_id (i.e. the
# thumbnail is not generated at the Work level)
describe "Generic Work Thumbnail Display:", type: :feature do
  let!(:current_user)  { create(:user) }

  context "A work with a thumbnail" do
    let!(:work)          { create(:work, :with_one_file, file_title: ["CSV Multifile-Report 1"], depositor: current_user.login) }
    let(:thumbnail_path) { main_app.download_path(work.thumbnail_id, file: 'thumbnail') }
    let(:mime_type)      { 'image/png' }

    before do
      sign_in(current_user)
      allow_any_instance_of(SolrDocument).to receive(:mime_type).and_return(mime_type)
      go_to_dashboard_works
    end

    after :all do
      Object.send(:remove_const, CurationConcerns::ThumbnailPathService)
    end

    module CurationConcerns
      class ThumbnailPathService
        class << self
          def thumbnail?(_thumb)
            # For testing pretend the file is always on disk.
            # There might be a more RSpec-y way of doing stubbing this method/class but I
            # couldn't get it to work so I am monkey patching the class directly.
            true
          end
        end
      end
    end

    it "renders the thumbnail" do
      expect(page).to have_css("img[src*='#{thumbnail_path}']")
    end
  end

  context "A work without a thumbnail" do
    let!(:work) { create(:public_work_without_filesets, file_title: ["CSV Multifile-Report 1"], depositor: current_user.login) }

    before do
      sign_in(current_user)
      go_to_dashboard_works
    end

    it "renders the default thumbnail" do
      expect(page).to have_css("img[src*='/assets/work-']")
    end
  end
end
