# frozen_string_literal: true
require 'rails_helper'

describe "Download requests", type: :request do
  let(:work) { create(:public_work) }
  subject { response }

  # Tests public/404.html.erb which is required by Hydra::Controller::DownloadBehavior#render_404
  context "with a missing image" do
    before { get "/downloads/#{work.id}" }
    it { is_expected.to be_not_found }
  end
end
