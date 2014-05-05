require 'spec_helper'

include Warden::Test::Helpers

describe_options = { type: :feature }
describe_options[:js] = true if ENV['JS']

describe 'batch editing', describe_options do
  before(:all) do
    @old_resque_inline_value = Resque.inline
    Resque.inline = true
  end

  after(:all) do
    Resque.inline = @old_resque_inline_value
    User.destroy_all
    Batch.destroy_all
    GenericFile.destroy_all
    Collection.destroy_all
  end

  describe 'all files' do
    let(:subject_value) { 'fffzzz' }

    before(:each) do
      @gf1 =  GenericFile.new.tap do |f|
        f.title = 'title 1'
        f.apply_depositor_metadata('jilluser')
        f.save
      end
      @gf2 =  GenericFile.new.tap do |f|
        f.title = 'title 2'
        f.apply_depositor_metadata('jilluser')
        f.save
      end
    end

    it "edits multiple files" do
      login_js
      go_to_dashboard
      first('input#check_all').click
      page.should have_css("div.batch-toggle[style*='display: block;']")
      click_button('Edit Selected')
      page.should have_content('2 files')
      page.should have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
      click_link('Subject')
      within('#collapse_subject') do
        fill_in('Subject', with: subject_value)
        click_button('subject_save')
      end
      page.find('#collapse_subject').should have_content('Changes Saved')
      within('#masthead_controls') do
        fill_in('search-field-header', with: subject_value)
        click_button("Go")
      end
      page.should have_content('Search Results')
      page.should have_content(@gf1.title.first)
      page.should have_content(@gf2.title.first)
    end

    it "deletes multiple files" do
      login_js
      go_to_dashboard
      first('input#check_all').click
      page.should have_css("div.batch-toggle[style*='display: block;']")
      click_button('Delete Selected')
      go_to_dashboard
      page.should have_content('My Dashboard')
      page.should_not have_content(@gf1.title.first)
      page.should_not have_content(@gf2.title.first)
    end
  end
end
