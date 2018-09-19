# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

describe Scholarsphere::Bagger do
  context 'making a bag in scholarsphere' do
    let(:test_dir) { Rails.root.join('tmp', 'test_bag') }
    let(:bin_data) { File.join(fixture_path, '4-20.png') }
    let(:txt_data) { File.join(fixture_path, 'test.txt') }
    let(:bin_sum) { 'f644910a516fa2effb0337304dabbadd0ae60d40a289ce0ece26be6bd4416d8c' }
    let(:txt_sum) { 'f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2' }

    before do
      Dir.mkdir(test_dir)
    end

    after do
      FileUtils.remove_dir(test_dir)
    end

    it 'creates a bag with the correct bin data' do
      described_class.new(full_path: Rails.root.join('tmp', 'test_bag'), working_file: bin_data)
      expect(File.directory?(Rails.root.join('tmp', 'test_bag'))).to eq(true)
      expect(File.readlines(Rails.root.join('tmp', 'test_bag', 'manifest-sha256.txt')).grep(/#{bin_sum}/)).not_to be_empty
    end

    it 'creates a bag with the correct text data' do
      described_class.new(full_path: Rails.root.join('tmp', 'test_bag'), working_file: txt_data)
      expect(File.directory?(Rails.root.join('tmp', 'test_bag'))).to eq(true)
      expect(File.readlines(Rails.root.join('tmp', 'test_bag', 'manifest-sha256.txt')).grep(/#{txt_sum}/)).not_to be_empty
    end

    it 'creates a bag with string' do
      described_class.new(full_path: Rails.root.join('tmp', 'test_bag'), string_data: File.open(txt_data).read, file_name: 'blah.txt')
      expect(File.directory?(Rails.root.join('tmp', 'test_bag'))).to eq(true)
      expect(File.readlines(Rails.root.join('tmp', 'test_bag', 'manifest-sha256.txt')).grep(/#{txt_sum}/)).not_to be_empty
      expect(File.exist?(Rails.root.join('tmp', 'test_bag', 'data', 'blah.txt'))).to eq(true)
    end

    context 'with a moveable file' do
      let(:temp_dir) { Rails.root.join('tmp') }
      let(:temp_file) { File.join(temp_dir, '4-20.png') }

      before do
        FileUtils.cp(bin_data, temp_dir)
      end
      it 'creates a bag with the correct bin data' do
        described_class.new(full_path: Rails.root.join('tmp', 'test_bag'), movable_file: temp_file)
        expect(File.directory?(Rails.root.join('tmp', 'test_bag'))).to eq(true)
        expect(File.readlines(Rails.root.join('tmp', 'test_bag', 'manifest-sha256.txt')).grep(/#{bin_sum}/)).not_to be_empty
      end
    end
  end
end
