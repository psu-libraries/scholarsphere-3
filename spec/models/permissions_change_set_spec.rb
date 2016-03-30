# frozen_string_literal: true
require 'spec_helper'

describe PermissionsChangeSet do
  describe "#added and #removed" do
    let(:no_perm)   { [] }
    let(:one_perm)  { [{ name: "abd123", type: "person", access: "edit" }] }
    let(:multi_perm) do
      [
        { name: "zzz123", type: "person", access: "edit" },
        { name: "def123", type: "person", access: "edit" }
      ]
    end

    subject { described_class.new(before.permissions.map(&:to_hash), after.permissions.map(&:to_hash)) }

    context "with no permissions after" do
      let(:after) { build(:file) }
      context "and no permissions before" do
        let(:before) { build(:file) }
        its(:added)   { is_expected.to be_empty }
        its(:removed) { is_expected.to be_empty }
      end
      context "and one permission before" do
        let(:before) { build(:file, edit_users: ['abd123']) }
        its(:added)   { is_expected.to be_empty }
        its(:removed) { is_expected.to eq(one_perm) }
      end
      context "and multiple permissions before" do
        let(:before) { build(:file, edit_users: ['zzz123', 'def123']) }
        its(:added)   { is_expected.to be_empty }
        its(:removed) { is_expected.to eq(multi_perm) }
      end
    end
    context "with one permission after" do
      let(:after) { build(:file, edit_users: ['abd123']) }
      context "and one permission before" do
        let(:before) { build(:file, edit_users: ['abd123']) }
        its(:added)   { is_expected.to be_empty }
        its(:removed) { is_expected.to be_empty }
      end
      context "and no permissions before" do
        let(:before) { build(:file) }
        its(:added)   { is_expected.to eq(one_perm) }
        its(:removed) { is_expected.to be_empty }
      end
      context "and multiple permissions before" do
        let(:before) { build(:file, edit_users: ['zzz123', 'def123']) }
        its(:added)   { is_expected.to eq(one_perm) }
        its(:removed) { is_expected.to eq(multi_perm) }
      end
    end
    context "with multiple permissions after" do
      let(:after) { build(:file, edit_users: ['zzz123', 'def123']) }
      context "and multiple permissions before" do
        let(:before) { build(:file, edit_users: ['zzz123', 'def123']) }
        its(:added)   { is_expected.to be_empty }
        its(:removed) { is_expected.to be_empty }
      end
      context "and no permissions before" do
        let(:before) { build(:file) }
        its(:added)   { is_expected.to eq(multi_perm) }
        its(:removed) { is_expected.to be_empty }
      end
      context "and one permission before" do
        let(:before) { build(:file, edit_users: ['abd123']) }
        its(:added)   { is_expected.to eq(multi_perm) }
        its(:removed) { is_expected.to eq(one_perm) }
      end
    end
  end

  describe "#privatized?" do
    subject { described_class.new(before.permissions.map(&:to_hash), after.permissions.map(&:to_hash)) }

    context "when going from public to private" do
      let(:before) { build(:public_file) }
      let(:after)  { build(:private_file) }
      it { is_expected.to be_privatized }
    end

    context "when going from private to public" do
      let(:before) { build(:private_file) }
      let(:after)  { build(:public_file) }
      it { is_expected.not_to be_privatized }
    end

    context "when visibility remains unchanged" do
      let(:before) { build(:file) }
      let(:after)  { build(:file) }
      it { is_expected.not_to be_privatized }
    end
  end

  describe "#publicized?" do
    subject { described_class.new(before.permissions.map(&:to_hash), after.permissions.map(&:to_hash)) }

    context "when going from public to private" do
      let(:before) { build(:public_file) }
      let(:after)  { build(:private_file) }
      it { is_expected.not_to be_publicized }
    end

    context "when going from private to public" do
      let(:before) { build(:private_file) }
      let(:after)  { build(:public_file) }
      it { is_expected.to be_publicized }
    end

    context "when visibility remains unchanged" do
      let(:before) { build(:file) }
      let(:after)  { build(:file) }
      it { is_expected.not_to be_publicized }
    end
  end
end
