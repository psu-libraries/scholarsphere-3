# frozen_string_literal: true
require 'rails_helper'

describe Import::VersionBuilder do
  let(:user) { create(:user) }
  let(:sufia6_user) { "s6user" }
  let(:sufia6_password) { "s6password" }
  let(:builder) { described_class.new }
  let(:file_set) { create(:file_set, user: user, label: 'my label.txt') }
  subject { file_set }

  let(:version1_uri) { "http://127.0.0.1:8983/fedora/rest/dev/44/55/8d/49/44558d49x/content/fcr:versions/version1" }
  let(:version2_uri) { "http://127.0.0.1:8983/fedora/rest/dev/44/55/8d/49/44558d49x/content/fcr:versions/version2" }
  let(:versions) do
    [
      { uri: version1_uri,
        created: "2016-09-28T20:00:14.658Z",
        label: "version1" },
      { uri: version2_uri,
        created: "2016-09-29T15:58:00.639Z",
        label: "version2" }
    ]
  end
  let(:version1) do
    file = Tempfile.new('version1')
    file.write("hello world! version1")
    file.rewind
    file
  end
  let(:version2) do
    file = Tempfile.new('version2')
    file.write("hello world! version2")
    file.rewind
    file
  end

  let(:http) { class_double("Net:HTTP") }
  let(:request) { class_double("Net::HTTP::Get") }

  let(:output_file) { Hydra::PCDM::File.find file_set.original_file.id }

  context "when username / password have not been configured" do
    it "raises runtime error" do
      expect { builder.build(file_set, versions) }.to raise_error RuntimeError
    end
  end
  context "when username / password are provided" do
    before do
      allow(builder).to receive(:sufia6_user).and_return(sufia6_user)
      allow(builder).to receive(:sufia6_password).and_return(sufia6_password)
      allow(builder).to receive(:open).with(version1_uri, http_basic_authentication: [sufia6_user, sufia6_password]).and_return(version1)
      allow(builder).to receive(:open).with(version2_uri, http_basic_authentication: [sufia6_user, sufia6_password]).and_return(version2)
    end
    after do
      version1.close
      version1.unlink
      version2.close
      version2.unlink
    end
    context "good http" do
      before do
        FileUtils.copy version1.to_path, File.join(Rails.root, "tmp/uploads", "#{file_set.id}_version1_#{file_set.label}")
        FileUtils.copy version2.to_path, File.join(Rails.root, "tmp/uploads", "#{file_set.id}_version2_#{file_set.label}")
      end
      it "creates versions" do
        expect(Net::HTTP).to receive(:start).twice
        expect(CharacterizeJob).to receive(:perform_now).with(file_set, anything, /.*version2_my label.txt/).and_return(true)
        builder.build(file_set, versions)
        expect(output_file.versions.all.map(&:label)).to contain_exactly("version1", "version2")
        expect(output_file.content).to eq("hello world! version2")
        expect(output_file.date_created).to eq(["2016-09-29T15:58:00.639Z"])
        expect(output_file.versions.all.map { |v| Hydra::PCDM::File.new(v.uri).date_created.first }).to contain_exactly("2016-09-28T20:00:14.658Z", "2016-09-29T15:58:00.639Z")
        expect(output_file.file_name).to eq ["my label.txt"]
      end
    end
    context "when fileset has nil id" do
      it "raises runtime error" do
        expect { builder.build(FileSet.new, versions) }.to raise_error("FileSet must have an id before importing any versions")
      end
    end
  end
end
