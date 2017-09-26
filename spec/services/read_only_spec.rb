# frozen_string_literal: true

require 'rails_helper'

describe ReadOnly do
  describe '#read_only?' do
    subject { described_class.read_only? }

    context 'configuration not set' do
      before do
        allow(ScholarSphere::Application.config).to receive(:respond_to?).with(:read_only).and_return(false)
      end
      it { is_expected.to be_falsey }
    end

    context 'read only flag false' do
      before do
        allow(ScholarSphere::Application.config).to receive(:read_only).and_return(false)
      end
      it { is_expected.to be_falsey }
    end

    context 'read only flag true' do
      before do
        allow(ScholarSphere::Application.config).to receive(:read_only).and_return(true)
      end
      it { is_expected.to be_truthy }
    end

    context "read only flag 'false'" do
      before do
        allow(ScholarSphere::Application.config).to receive(:read_only).and_return('false')
      end
      it { is_expected.to be_falsey }
    end

    context "read only flag 'true'" do
      before do
        allow(ScholarSphere::Application.config).to receive(:read_only).and_return('true')
      end
      it { is_expected.to be_truthy }
    end
  end

  describe '#announcement_text' do
    subject { described_class.announcement_text }

    before do
      allow(ContentBlock).to receive(:find_by).and_return(content_block)
    end

    context 'no homepage announcement' do
      let(:content_block) { instance_double ContentBlock, value: '' }

      it { is_expected.to eq('The system is currently in read only mode for maintenance. Please try again later to upload or modify your ScholarSphere content.') }
    end

    context 'homepage announcement' do
      let(:content_block) { instance_double ContentBlock, value: 'Announcment' }

      it { is_expected.to eq('Announcment') }
    end
  end
end
