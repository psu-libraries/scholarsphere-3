# frozen_string_literal: true

require 'rails_helper'

describe Scholarsphere::Config do
  describe '::check' do
    context 'with our current configuration files' do
      it 'checks the contents of our production configuration files' do
        expect { described_class.check }.not_to raise_error(Scholarsphere::Config::Error)
        expect(FileSet.image_mime_types).to eq(['image/png', 'image/jpeg', 'image/jpg', 'image/jp2', 'image/bmp', 'image/gif'])
      end
    end

    context 'with a sample config file' do
      before { allow(Dir).to receive(:glob).and_return([File.join(fixture_path, 'application.yml')]) }

      it 'raises an error' do
        expect { described_class.check }.to raise_error(Scholarsphere::Config::Error, start_with('Config file'))
      end
    end
  end
end
