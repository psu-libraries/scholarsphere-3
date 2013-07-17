require 'spec_helper'

include Warden::Test::Helpers

describe_options = {type: :feature}
if ENV['JS']
  describe_options[:js] = true
end

describe 'end to end behavior', describe_options do
  before(:each) do
    @old_resque_inline_value = Resque.inline
    Resque.inline = true
  end
  after(:each) do
    Resque.inline = @old_resque_inline_value
  end
  after(:all) do
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
      if page.html.index "Login"      
         debugger      
         visit('/')
      end
      click_link('Share Your Work')
      check("terms_of_service")
      test_file_path = Rails.root.join('spec/fixtures/world.png').to_s
      file_format = 'png (Portable Network Graphics)'
      
      page.execute_script(%Q{$("input[type=file]").css("opacity", "1").css("-moz-transform", "none");$("input[type=file]").attr('id',"fileupload");})
      
       attach_file "fileupload", test_file_path
      page.first('.start').click
      wait_until(30) do
        page.has_content?('Apply Metadata')
      end
      fill_in('Title 1', :with => 'MY Tite for World')
      first('i.icon-question-sign').click
      fill_in('Keyword', :with => 'test')
      fill_in('Creator', :with => 'me')
      click_on('upload_submit')
      wait_until(30) do
        page.has_content?('Dashboard')
      end
      page.has_content?('world.png').should be_true
      page.has_content?('MY Tite for World').should be_true
      within('#facets') do
        # I call CSS/Dom shenannigans; I can't access 'Creator' link
        # directly and instead must find by CSS selector, validate it
        all('a.accordion-toggle').each do |elem|
          if elem.text == 'File Format'
            elem.click
          end
        end
        click_on(file_format)
      end
      wait_until(30) do
        page.has_content?('Dashboard')
      end
      within('.alert-warning') do
        page.should have_content(file_format)
      end
      
      page.has_content?('world.png').should be_true
      page.has_content?('MY Tite for World').should be_true

      first('button.dropdown-toggle').click
      click_link('Edit File')
      wait_on_page('Edit MY Tite for World').should be_true
      first('i.icon-question-sign').click
      #todo more test for edit?

      click_link('Dashboard')
      count = all('button.dropdown-toggle').count
      1.upto(count) do
        first('button.dropdown-toggle').click
        click_link('Delete File')
        page.driver.browser.switch_to.alert.accept
      end
      
      
    end
  end
end
