# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'scholarsphere:resque' do
  before do
    load_rake_environment ["#{Rails.root}/lib/tasks/scholarsphere/resque.rake"]
  end

  let(:file_name) { Rails.root.join('tmp/resque_count.txt') }
  let(:output_file) { File.new(file_name) }

  describe 'count' do
    context 'without errors', clean: true do
      it 'has no errors' do
        output = capture_stdout { Rake::Task['scholarsphere:resque:count'].invoke }
        expect(output).to be_blank
        expect(File).to be_exists(file_name)
        expect(output_file.read).to eq("0\n")
      end
    end

    context 'with errors', clean: true do
      before do
        allow(Resque::Failure).to receive(:count).and_return(20)
      end

      it 'has no errors' do
        output = capture_stdout { Rake::Task['scholarsphere:resque:count'].invoke }
        expect(output).to be_blank
        expect(File).to be_exists(file_name)
        expect(output_file.read).to eq("20\n")
      end
    end
  end
end
