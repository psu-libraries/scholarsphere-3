require_relative 'feature_spec_helper'

describe 'proxy' do

  let!(:current_user) { create :user }
  let!(:second_user) { create :user }

  describe 'create a proxy' do

    it "should create proxy" do
      sign_in_as current_user
      visit '/'
      first('a.dropdown-toggle').click
      click_link('edit profile')
      first("td.depositor-name").should be_nil
      create_proxy_using_partial second_user
      page.should have_css "table#authorizedProxies td.depositor-name", text: second_user.display_name
    end
  end

  describe 'use a proxy' do

    before (:each) do
      @rights = ProxyDepositRights.create!(grantor: second_user, grantee: current_user)
    end

    it "should allow for on behalf deposit" do
      sign_in_as current_user
      visit '/'
      first('a.dropdown-toggle').click
      click_link('upload')
      page.should have_content('I have read')
      check("terms_of_service")
      select(second_user.login, from: 'on_behalf_of')
      test_file_path = Rails.root.join('spec/fixtures/world.png').to_s
      page.execute_script(%Q{$("input[type=file]").css("opacity", "1").css("-moz-transform", "none");$("input[type=file]").attr('id',"fileselect");})
      attach_file("fileselect", test_file_path)
      page.first('.start').click
      page.should have_content('Apply Metadata')
      fill_in('generic_file_title', with: 'MY Title for the World')
      fill_in('generic_file_tag', with: 'test')
      fill_in('generic_file_creator', with: 'me')
      click_on('upload_submit')
      click_link "Shared with Me"
      page.should have_content "MY Title for the World"
      first('i.glyphicon-chevron-right').click
      click_link(second_user.display_name)
    end
  end
end
