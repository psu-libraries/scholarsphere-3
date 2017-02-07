# frozen_string_literal: true
require 'spec_helper'

describe Export::CollectionConverter do
  let(:collection) { create :collection }
  let(:permission) { collection.permissions.first }
  let(:permission2) { collection.permissions.last }
  let(:json) { "{\"id\":\"#{collection.id}\",\"title\":\"My collection\",\"description\":\"My incredibly detailed description of the collection\",\"creator\":[\"The Collector\"],\"members\":[],\"permissions\":[{\"id\":\"#{permission.id}\",\"agent\":\"http://projecthydra.org/ns/auth/group#public\",\"mode\":\"http://www.w3.org/ns/auth/acl#Read\",\"access_to\":\"#{collection.id}\"},{\"id\":\"#{permission2.id}\",\"agent\":\"http://projecthydra.org/ns/auth/person#user\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{collection.id}\"}],\"depositor\":\"user\"}" }

  describe "to_json" do
    subject { described_class.new(collection).to_json }
    it { is_expected.to eq(json) }
  end
end
