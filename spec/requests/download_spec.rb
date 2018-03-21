# frozen_string_literal: true

require 'rails_helper'

describe 'Download requests', type: :request do
  subject { response }

  context 'with a missing image' do
    before { get '/downloads/1234' }
    its(:status) { is_expected.to eq(500) }
  end
end
