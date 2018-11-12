# frozen_string_literal: true

require 'feature_spec_helper'

describe GenericWork, type: :feature, js: true do
  context 'when viewing a work with many files' do
    let(:current_user) { create(:user) }
    let(:number_of_files) { 21 }

    # Build 21 file sets
    let(:file_sets) do
      (1..number_of_files).map do |id|
        build(:file_set, :with_file_size,
              id: "multifile#{id}",
              title: ["File #{id}"],
              user: current_user)
      end
    end

    # Build a work that contains the 100 file sets
    let(:work) do
      build(:work, :with_complete_metadata,
            id: 'bigwork',
            depositor: current_user.login,
            representative_id: 'multifile20',
            members: file_sets)
    end

    # Create a list source record that specifies an order for the file sets
    let(:list_source) do
      HashWithIndifferentAccess.new(ActiveFedora::Aggregation::ListSource.new.to_solr)
        .merge(id: "#{work.id}/list_source")
        .merge(proxy_in_ssi: work.id.to_s)
        .merge(ordered_targets_ssim: file_sets.map(&:id))
    end

    # Index everything in solr as opposed to creating it, which would take a very long time!
    before do
      file_sets.each { |fs| index_file_set(fs, commit_now: false) }
      index_document(list_source, commit_now: false)
      index_work(work)
      login_as(current_user)
      visit('/concern/generic_works/bigwork')
    end

    after do
      file_sets.each { |fs| ActiveFedora::SolrService.instance.conn.delete_by_id fs.id }
      ActiveFedora::SolrService.instance.conn.delete_by_id "#{work.id}/list_source"
      ActiveFedora::SolrService.instance.conn.delete_by_id work.id
      ActiveFedora::SolrService.commit
    end

    it 'displays the work page with pagination and each page has 10 files' do
      within('dl.attributes') do
        expect(page).to have_selector('dd.total_items', text: number_of_files.to_s)
      end
      within('table.related-files') do
        (1..10).each do |id|
          expect(page).to have_link("File #{id}")
        end
      end
      within('div.pager') do
        click_link('2')
      end
      within('table.related-files') do
        (11..20).each do |id|
          expect(page).to have_link("File #{id}")
        end
      end
    end
  end
end
