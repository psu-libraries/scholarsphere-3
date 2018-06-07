# frozen_string_literal: true

require 'rails_helper'

describe EncodingService do
  context 'with an encodable string' do
    let(:string) { File.open(File.join(fixture_path, 'bad_readme.md'), 'rb').read }

    it 'encodes the characters to UTF-8' do
      expect(string.encoding.name).to eq('ASCII-8BIT')
      expect(described_class.call(string).encoding.name).to eq('UTF-8')
    end
  end

  context 'with an unencodeable string' do
    let(:string) { instance_double(String) }

    before { allow(string).to receive(:encode).and_raise(StandardError, 'bad encoding') }

    it 'returns a string with the error' do
      expect(described_class.call(string)).to eq('Error encoding readme as UTF-8: bad encoding')
    end
  end
end
