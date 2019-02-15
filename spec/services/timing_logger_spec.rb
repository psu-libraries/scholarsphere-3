# frozen_string_literal: true

require 'rails_helper'

describe TimingLogger do
  let(:logger) { described_class.new(logname) }
  let(:logname) { Rails.root.join('log', 'timing_test.log') }

  context 'disabled' do
    describe '#log' do
      it 'does nothing' do
        logger.log(action: 'sending some data', start_time: Time.now)
        expect(File).not_to be_exist(logname)
      end
    end
  end

  context 'enabled' do
    before do
      allow(ENV).to receive(:fetch).with('timing_enabled', 'false').and_return('true')
    end

    after do
      FileUtils.rm(logname)
    end

    describe '#log' do
      it 'does nothing' do
        logger.log(action: 'sending some data', start_time: Time.now)
        expect(File).to be_exist(logname)
      end
    end
  end
end
