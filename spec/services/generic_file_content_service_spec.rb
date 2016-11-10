# frozen_string_literal: true
require 'spec_helper'

describe GenericFileContentService do
  let!(:service) { described_class.new(generic_file) }
  let(:import_file_name) { fixture_path + '/little_file.txt' }

  describe "#stream_content" do
    after do
      service.cleanup
    end

    context "with import file url" do
      subject { service.stream_content.path }
      let(:generic_file) { create(:file, import_url: 'file://' + import_file_name) }
      it { is_expected.to eq(import_file_name) }
    end

    describe "returns temp file" do
      subject { service.stream_content.class }

      context "with import http url" do
        let(:generic_file) { create(:file, :with_pdf, import_url: 'http://example.com') }
        it { is_expected.to eq(File) }
        it "contains the content" do
          expect(FileUtils.identical?(service.stream_content, File.open("#{Rails.root}/spec/fixtures/scholarsphere/scholarsphere_test4.pdf", 'rb'))).to be_truthy
        end
      end

      context "with content" do
        let(:generic_file) { create(:file, :with_pdf) }
        it { is_expected.to eq(File) }
        it "contains the content" do
          expect(FileUtils.identical?(service.stream_content, File.open("#{Rails.root}/spec/fixtures/scholarsphere/scholarsphere_test4.pdf", 'rb'))).to be_truthy
        end
      end
    end
  end

  describe "#cleanup" do
    context "temp file exists" do
      let(:generic_file) { create(:file, :with_pdf) }
      let!(:stream) { service.stream_content }
      let!(:path) { stream.path }
      it "removes the file" do
        expect(File.exist?(path)).to be_truthy
        service.cleanup
        expect(File.exist?(path)).to be_falsey
      end
    end
  end
end
