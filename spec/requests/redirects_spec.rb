# frozen_string_literal: true
require 'rails_helper'

describe 'Redirects', type: :request do
  subject { response }

  context 'from /landing_page/new' do
    before { get '/landing_page/new' }
    it { is_expected.to redirect_to('/contact') }
  end

  context 'from /managedata' do
    before { get '/managedata' }
    it { is_expected.to redirect_to('/contact') }
  end
end
