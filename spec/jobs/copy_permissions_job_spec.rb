# frozen_string_literal: true
require "rails_helper"

describe CopyPermissionsJob do
  context "when changing visibility" do
    let(:work)     { create(:public_work, edit_users: ["user1"]) }
    let(:file_set) { create(:file_set) }

    subject { file_set }

    before do
      work.ordered_members = [file_set]
      work.save
      described_class.perform_now(work)
    end

    its(:visibility) { is_expected.to eq("open") }
  end

  # This duplicates Sufia's InheritPermissionsJob spec tests
  context "when changing permissions" do
    let(:user) { create(:user, login: "user") }
    let(:work) { create(:work, :with_one_file, user: user) }

    before do
      work.permissions.build(name: name, type: type, access: access)
      work.save
    end

    context "when edit people change" do
      let(:name) { "abc@123.com" }
      let(:type) { "person" }
      let(:access) { "edit" }

      it "copies permissions to its contained files" do
        # files have the depositor as the edit user to begin with
        expect(work.file_sets.first.edit_users).to eq [user.to_s]

        described_class.perform_now(work)
        work.reload.file_sets.each do |file|
          expect(file.edit_users).to match_array [user.to_s, "abc@123.com"]
        end
      end

      context "when people should be removed" do
        before do
          file_set = work.file_sets.first
          file_set.permissions.build(name: "remove_me", type: type, access: access)
          file_set.save
        end

        it "copies permissions to its contained files" do
          # files have the depositor as the edit user to begin with
          expect(work.file_sets.first.edit_users).to eq [user.to_s, "remove_me"]

          described_class.perform_now(work)
          work.reload.file_sets.each do |file|
            expect(file.edit_users).to match_array [user.to_s, "abc@123.com"]
          end
        end
      end
    end

    context "when read people change" do
      let(:name) { "abc@123.com" }
      let(:type) { "person" }
      let(:access) { "read" }

      it "copies permissions to its contained files" do
        # files have the depositor as the edit user to begin with
        expect(work.file_sets.first.read_users).to eq []

        described_class.perform_now(work)
        work.reload.file_sets.each do |file|
          expect(file.read_users).to match_array ["abc@123.com"]
          expect(file.edit_users).to match_array [user.to_s]
        end
      end
    end

    context "when read groups change" do
      let(:name) { "my_read_group" }
      let(:type) { "group" }
      let(:access) { "read" }

      it "copies permissions to its contained files" do
        # files have the depositor as the edit user to begin with
        expect(work.file_sets.first.read_groups).to eq []

        described_class.perform_now(work)
        work.reload.file_sets.each do |file|
          expect(file.read_groups).to match_array ["my_read_group"]
          expect(file.edit_users).to match_array [user.to_s]
        end
      end
    end

    context "when edit groups change" do
      let(:name) { "my_edit_group" }
      let(:type) { "group" }
      let(:access) { "edit" }

      it "copies permissions to its contained files" do
        # files have the depositor as the edit user to begin with
        expect(work.file_sets.first.read_groups).to eq []

        described_class.perform_now(work)
        work.reload.file_sets.each do |file|
          expect(file.edit_groups).to match_array ["my_edit_group"]
          expect(file.edit_users).to match_array [user.to_s]
        end
      end
    end
  end
end
