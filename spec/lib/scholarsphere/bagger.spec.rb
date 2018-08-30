# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

describe Scholarsphere::Bagger do
  context 'making a bag in scholarsphere' do
    before do
      bin_dir = Rails.root.join('tmp', 'bin_bag')
      txt_dir = Rails.root.join('tmp', 'txt_bag')
      Dir.mkdir(bin_dir) unless File.directory?(bin_dir)
      Dir.mkdir(txt_dir) unless File.directory?(txt_dir)
    end

    let(:bin_data) { File.join(fixture_path, '4-20.png') }
    let(:txt_data) { File.join(fixture_path, 'test.txt') }
    let(:bin_sum) { '247af6a45ec9dfc6649f3d1ee0a81cfa1b6a25bfebd8922e4a471a0692746be' }
    let(:txt_sum) { 'f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2' }

    it 'creates a bag with the correct bin data' do
      described_class.new(full_path: Rails.root.join('tmp', 'bin_bag'), working_file: bin_data)
      expect(File.directory?(Rails.root.join('tmp', 'bin_bag'))).to eq(true)
      expect(File.readlines(Rails.root.join('tmp', 'bin_bag', 'manifest-sha256.txt')).grep(/#{bin_sum}/)).not_to be_empty
      FileUtils.remove_dir(Rails.root.join('tmp', 'bin_bag'))
    end

    it 'creates a bag with the correct text data' do
      described_class.new(full_path: Rails.root.join('tmp', 'txt_bag'), working_file: txt_data)
      expect(File.directory?(Rails.root.join('tmp', 'bin_bag'))).to eq(true)
      expect(File.readlines(Rails.root.join('tmp', 'txt_bag', 'manifest-sha256.txt')).grep(/#{txt_sum}/)).not_to be_empty
      FileUtils.remove_dir(Rails.root.join('tmp', 'txt_bag'))
    end
  end
end
