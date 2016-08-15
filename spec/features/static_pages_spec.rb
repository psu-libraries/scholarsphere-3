# frozen_string_literal: true
require 'feature_spec_helper'

describe 'Static pages:', type: :feature do
  shared_examples "a page with links" do
    it "has links to external pages", unless: travis? do
      external_links.each do |link|
        visit(link)
        expect(status_code).to eq(200)
      end
    end

    it "has links to anchors" do
      anchor_links.each do |link|
        visit(link)
        expect(status_code).to eq(200)
      end
    end
  end

  shared_examples "a page with YouTube links" do
    it "has links to YouTube videos", unless: travis? do
      youtube_links.each do |link|
        visit(link)
        expect(status_code).to eq(200)
      end
    end
  end

  context 'when not logged in' do
    before do
      sign_in_with_named_js(:error_polergeist, nil, js_errors: false)
      visit(path)
    end

    describe "the about page" do
      let(:path) { "/about" }
      it_behaves_like "a page with links"
    end

    describe "the contact page" do
      let(:path) { "/contact" }
      it_behaves_like "a page with links"
    end

    describe "the help page" do
      let(:path) { "/help" }
      it_behaves_like "a page with YouTube links"
      it_behaves_like "a page with links"
    end
  end

  context 'when logged in' do
    let(:user) { create(:user) }
    before do
      sign_in_with_named_js(:error_polergeist, user, js_errors: false)
      visit(path)
    end

    describe "the about page" do
      let(:path) { "/about" }
      it_behaves_like "a page with links"
    end

    describe "the contact page" do
      let(:path) { "/contact" }
      it_behaves_like "a page with links"
    end

    describe "the help page" do
      let(:path) { "/help" }
      it_behaves_like "a page with YouTube links"
      it_behaves_like "a page with links"
    end
  end
end
