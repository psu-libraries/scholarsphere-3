# frozen_string_literal: true
require 'spec_helper'

describe Export::VersionConverter do
  let(:user) { create :jill }
  let(:file) { create :file, :with_png, depositor: user.login }
  let(:version_graph) { file.content.versions }
  let(:version_uri) { file.content.versions.first.uri }
  let(:version_label) { file.content.versions.first.label }
  let(:version_created) { VersionCommitter.first.created_at.strftime '%Y-%m-%dT%H:%M:%S.%3NZ' }
  let(:json) { "{\"uri\":\"#{version_uri}\",\"created\":\"#{version_created}\",\"label\":\"#{version_label}\",\"created_by\":\"#{user.login}\"}" }

  describe "to_json" do
    before { file.record_version_committer(user) }
    subject { described_class.new(version_uri, version_graph).to_json }
    it { is_expected.to eq(json) }
  end
end
