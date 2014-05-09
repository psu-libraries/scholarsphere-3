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
      fill_in('Title 1', :with => 'MY Tite for World')
      first('i.glyphicon-question-sign').click
      fill_in('Keyword', :with => 'test')
      fill_in('Creator', :with => 'me')
      click_on('upload_submit')
      page.should have_content('Dashboard')
      page.should have_content('MY Tite for World')
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
      page.should have_content('MY Tite for World')
      within('#documents') do
        first('button.dropdown-toggle').click
        click_link('Edit File')
      end
      wait_on_page('Edit MY Tite for World').should be_true
      first('i.glyphicon-question-sign').click
      # TODO: more test for edit?
      click_link('Dashboard')
      within('#documents') do
        count = all('button.dropdown-toggle').count
        1.upto(count) do
          first('button.dropdown-toggle').click
          click_link('Delete File')
        end
      end
      # TODO: should we verify the deletes worked? feels like this
      #       test ends abruptly.
    end
  end
end
