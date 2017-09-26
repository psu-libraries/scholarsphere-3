# frozen_string_literal: true

require 'rails_helper'

describe ContentBlock do
  subject { described_class.license_text }

  let!(:content_block) { create(:license_text) }

  describe '::license_text' do
    its(:value) { is_expected.to eq('License here, license there, license everywhere') }
  end

  describe '::license_text=' do
    before { described_class.license_text = 'new value' }
    its(:value) { is_expected.to eq('new value') }
  end
end
