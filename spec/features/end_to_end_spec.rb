require 'spec_helper'

include Warden::Test::Helpers

describe_options = { type: :feature }
describe_options[:js] = true if ENV['JS']

describe 'end to end behavior', describe_options do

  before(:all) do
    @old_resque_inline_value = Resque.inline
    Resque.inline = true
  end

  after(:all) do
    Resque.inline = @old_resque_inline_value
    User.destroy_all
    Batch.destroy_all
  end

  let(:user) { FactoryGirl.find_or_create(:user) }
  let(:prefix) { Time.now.strftime("%Y-%m-%d-%H-%M-%S-%L") }
  let(:initial_title) { "#{prefix} Something Special" }
  let(:initial_file_path) { __FILE__ }
  let(:updated_title) { "#{prefix} Another Not Quite" }
  let(:updated_file_path) { Rails.root.join('app/controllers/application_controller.rb').to_s }

  describe 'upload a file' do
    let(:agreed_to_terms_of_service) { false }

    it "should show up on dashboard", js: true do
      login_js
      visit '/'
      click_link('Share Your Work')
      check("terms_of_service")
      test_file_path = Rails.root.join('spec/fixtures/world.png').to_s
      file_format = 'png (Portable Network Graphics)'
      page.execute_script(%Q{$("input[type=file]").css("opacity", "1").css("-moz-transform", "none");$("input[type=file]").attr('id',"fileselect");})
      attach_file("fileselect", test_file_path)
      page.first('.start').click
      page.should have_content('Apply Metadata')
      fill_in('generic_file_title', with: 'MY Title for the World')
      fill_in('generic_file_tag', with: 'test')
      fill_in('generic_file_creator', with: 'me')
      page.should have_css('#rightsModal.modal[aria-hidden*="true"]', visible: false)
      click_link('License Descriptions')
      sleep(1)
      page.should have_content('ScholarSphere License Descriptions')
      click_on('Close')
      sleep(1)
      page.should_not have_content('ScholarSph7ere License Descriptions')
      page.should have_css('#rightsModal', visible: false)
      click_link("What's this")
      sleep(1)
      page.should have_content('ScholarSphere Permissions')
      click_on('Close')
      sleep(1)
      page.should_not have_content('ScholarSphere Permissions')
      page.should have_css('#myModal', visible: false)
      page.should have_css('#myModal.modal[aria-hidden*="true"]', visible: false)
      page.should have_content('Save')
      click_on('upload_submit')
      URI(current_url).path.should == Sufia::Engine.routes.url_helpers.dashboard_files_path
      page.should have_content('Browse By')
      page.should have_content('MY Title for the World')
      within('#facets') do
        # I call CSS/DOM shenanigans; I can't access 'Creator' link
        # directly and instead must find by CSS selector, validate it
        all('a.accordion-toggle').each do |elem|
          elem.click if elem.text == 'File Format'
        end
        within ('#collapse_File_Format_db') do
          click_on(file_format)
        end
      end
      page.should have_content('X png (Portable Network Graphics)')
      page.should have_no_content("Your files are being processed by ScholarSphere in the background.")
      page.should have_content(file_format)
      within('.alert-warning') do
        page.should have_content(file_format)
      end
      page.should have_content('MY Title for the World')
      within('#documents') do
        first('button.dropdown-toggle').click
        click_link('Edit File')
      end
      page.should have_content('Edit MY Title for the World')
      first('i.glyphicon-question-sign').click
      # TODO: more test for edit?
      go_to_dashboard_files
      count = 0
      within('#documents') do
        count = all('button.dropdown-toggle').count
      end
      1.upto(count) do
        within('#documents') do
          first('button.dropdown-toggle').click
          click_link('Delete File')
        end
        URI(current_url).path.should == Sufia::Engine.routes.url_helpers.dashboard_files_path
      end
      within('#documents') do
        all('button.dropdown-toggle').count.should == 0
      end
    end
  end
end
