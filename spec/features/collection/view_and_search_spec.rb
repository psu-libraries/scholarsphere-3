require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Collection viewing and searching:' do

  let!(:current_user) { create :user }
  let(:filenames) { %w{world.png little_file.txt} }
  let(:title) { 'Test Collection Title' }
  let(:creator) { 'Test Creator Name' }
  let(:description) { 'Description for our test collection.' }

  describe 'logged in user' do
    let(:collection) { Collection.first }

    before do
      sign_in_as current_user
      filenames.each do |filename|
        create_file current_user, { title: [filename], creator: "#{filename}_creator" }
      end
      go_to_dashboard_files
      check 'check_all'
      click_button 'Add to Collection'
      db_create_populated_collection_button.click
      create_collection title, creator, [description]
      visit '/dashboard/collections'
      db_item_title(collection).click
    end

    let(:file_1) { find_file_by_title "world.png" }
    let(:file_2) { find_file_by_title "little_file.txt" }

    describe 'When viewing a collection' do
      specify "I should see the collection's metadata" do
        page.should have_content title
        page.should have_content description
        page.should have_content creator
        page.should have_content file_1.title.first
        page.should have_content file_2.title.first
        page.should have_content "Total Items 2"
        page.should have_content "Size 0 Bytes"
      end
      specify "I should see the collection name when viewing the file" do
        go_to_dashboard_files
        page.should have_content "Is part of: #{title}"
      end
      specify "I should see the breadcrumb trail" do
        page.should have_link("My Dashboard")
        page.should have_link("My Collections")
      end
    end

    describe 'When searching within a collection' do
      before do
        fill_in 'collection_search', with: file_1.title.first
        click_button 'collection_submit'
      end
      specify 'I should see the correct results' do
        page.should have_content title
        page.should have_content description

        # Should have search results / contents listing
        page.should have_content file_1.title.first
        page.should_not have_content file_2.title.first

        # Should not have Collection Descriptive metadata table
        page.should_not have_content creator
      end
    end
  end

  describe 'unkown user' do
    let(:gf_title) {'Test Document PDF'}
    let(:gf) { GenericFile.new(title: [gf_title], filename: ['test.pdf'], read_groups:['public']).tap do |gf|
                  gf.apply_depositor_metadata(current_user.user_key)
                  gf.save!
                end
              }
    let(:collection) { Collection.new(title: [title]).tap do |col|
                         col.apply_depositor_metadata(current_user.user_key)
                         col.members << gf
                         col.save!
                       end }

    before do
      visit "/collections/#{collection.noid}"
    end

    specify "I should not get and error" do
      expect(page.status_code).to eql(200)
      expect(page).to have_content title
      expect(page).to have_content gf_title
    end
  end
end
