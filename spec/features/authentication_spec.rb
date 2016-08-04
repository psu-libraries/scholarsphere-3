# frozen_string_literal: true
require 'feature_spec_helper'

describe 'Site authentication', type: :feature do
  context 'When I am not signed in' do
    describe 'And I click Login from the home page' do
      specify 'I should be redirected to the appropriate central login page' do
        visit '/'
        click_on 'Login'
        expect(unescape(current_url)).to eq(centralized_login_url)
      end
    end
    describe 'And I attempt to visit a restricted page on the site' do
      specify 'The restricted path should be included in my redirected url' do
        visit '/dashboard'
        expect(unescape(current_url)).to eq(centralized_login_url)
      end
    end
    describe 'And I try to upload a file' do
      specify 'It should take me back to the upload page after I have logged in' do
        pending("Need to apply configuration changes to login_url")
        visit '/concern/generic_works/new'
        expect(unescape(current_url)).to eq(centralized_login_url.gsub(/dashboard/, "concern/generic_works/new"))
      end
    end
  end

  def centralized_login_url
    Sufia::Engine.config.login_url
  end

  def unescape(url)
    URI.unescape(url)
  end
end
