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
    before do
      # this code is needed if the system has the correct sufia_6 paswords set to make this test fail
      ScholarSphere::Application.config.fedora_sufia6_user = 'abc'
      allow(ScholarSphere::Application.config).to receive(:fedora_sufia6_user).and_raise(NoMethodError)
    end
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
        allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(false)
        copy_version(version1, 'version1', file_set)
        copy_version(version2, 'version2', file_set)
      end
      it "creates versions" do
        expect(Net::HTTP).to receive(:start).twice
        expect(CharacterizeJob).to receive(:perform_now).with(file_set, anything, /.*version2_my_label.txt/).and_return(true)
        builder.build(file_set, versions)
        expect(output_file.versions.all.map(&:label)).to contain_exactly("version1", "version2")
        expect(output_file.content).to eq("hello world! version2")
        expect(output_file.date_created).to eq(["2016-09-29T15:58:00.639Z"])
        expect(output_file.versions.all.map { |v| Hydra::PCDM::File.new(v.uri).date_created.first }).to contain_exactly("2016-09-28T20:00:14.658Z".to_datetime, "2016-09-29T15:58:00.639Z".to_datetime)
        expect(output_file.file_name).to eq ["my label.txt"]
      end
    end
    context "bad http" do
      let(:bad_http_response) { Net::HTTPInternalServerError.new("1.1", "500", "Internal Error") }
      before do
        allow(bad_http_response).to receive(:body).and_return("Bad error")
        allow(Net::HTTP).to receive(:start).and_yield http
        allow(http).to receive(:request).with(an_instance_of(Net::HTTP::Get)).and_yield(bad_http_response)
      end
      it "raises an error" do
        expect { builder.build(file_set, versions) }.to raise_error(Net::HTTPFatalError)
      end
    end
    context "when fileset has nil id" do
      it "raises runtime error" do
        expect { builder.build(FileSet.new, versions) }.to raise_error("FileSet must have an id before importing any versions")
      end
    end

    context "when version date should be translated" do
      let(:generic_file_id) { 'zk51vg948' }
      let(:import_directory) { File.join(fixture_path, 'import') }
      let(:json_file_name) { File.join(import_directory, "generic_file_#{generic_file_id}.json") }
      let(:generic_file_metadata) { JSON.parse(File.read(json_file_name), symbolize_names: true) }
      let(:versions) { generic_file_metadata[:versions] }
      let(:version1_uri) { versions[0][:uri] }
      let(:version2_uri) { versions[1][:uri] }

      before do
        allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(false)
        copy_version(version1, 'version1', file_set)
        copy_version(version2, 'version2', file_set)
        file_set.date_uploaded = DateTime.parse("2013-03-09T20:43:36.592+00:00")
      end

      it "changes the date" do
        expect(Net::HTTP).to receive(:start).twice
        expect(CharacterizeJob).to receive(:perform_now).with(file_set, anything, /.*version2_my_label.txt/).and_return(true)
        builder.build(file_set, versions)
        expect(output_file.versions.all.map(&:label)).to contain_exactly("version1", "version2")
        expect(output_file.content).to eq("hello world! version2")
        expect(output_file.date_created).to eq(["2013-03-09T20:43:36.592+00:00"])
        expect(output_file.versions.all.map { |v| Hydra::PCDM::File.new(v.uri).date_created.first }).to contain_exactly(file_set.date_uploaded, file_set.date_uploaded)
        expect(output_file.file_name).to eq ["my label.txt"]
      end
    end
  end

  def copy_version(version, version_label, file_set)
    to_path = File.join(Rails.root, "tmp/uploads", "#{file_set.id}_#{version_label}_#{file_set.label.tr(' ', '_')}")
    puts to_path
    FileUtils.copy version.to_path, to_path
  end
end
