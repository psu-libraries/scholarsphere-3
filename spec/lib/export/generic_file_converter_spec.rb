# frozen_string_literal: true
require 'spec_helper'

describe Export::GenericFileConverter do
  let(:user) { create :jill }
  let(:file) { create :file, :with_png, depositor: user.login }
  let(:version_graph) { file.content.versions }
  let(:version_uri) { file.content.versions.first.uri }
  let(:version_label) { file.content.versions.first.label }
  let(:version_created) { VersionCommitter.first.created_at.strftime '%Y-%m-%dT%H:%M:%S.%3NZ' }
  let(:permission_id) { file.permissions[0].id }
  let(:label_value) { "no_original_label.txt" }
  let(:json) { "{\"id\":\"#{file.id}\",\"label\":\"#{label_value}\",\"depositor\":\"jilluser\",\"arkivo_checksum\":null,\"relative_path\":null,\"import_url\":null,\"resource_type\":[],\"title\":[\"Sample Title\"],\"creator\":[],\"contributor\":[],\"description\":[],\"tag\":[],\"rights\":[],\"publisher\":[],\"date_created\":[],\"date_uploaded\":null,\"date_modified\":null,\"subject\":[],\"language\":[],\"identifier\":[],\"based_near\":[],\"related_url\":[],\"bibliographic_citation\":[],\"source\":[],\"visibility\":\"restricted\",\"versions\":[{\"uri\":\"#{version_uri}\",\"created\":\"#{version_created}\",\"label\":\"#{version_label}\",\"created_by\":\"#{user.login}\"}],\"permissions\":[{\"id\":\"#{permission_id}\",\"agent\":\"http://projecthydra.org/ns/auth/person#jilluser\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{file.id}\"}]}" }

  describe "to_json" do
    before { file.record_version_committer(user) }
    subject { described_class.new(file).to_json }
    it { is_expected.to eq(json) }

    context "file label is set" do
      let(:label_value) { "abc123.mp3" }
      before { file.label = label_value }

      it { is_expected.to eq(json) }
    end
  end
end
