# frozen_string_literal: true
require 'rails_helper'

describe BatchEditsController do
  let(:user) { create(:user) }

  before do
    allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end

  describe "#form_class" do
    subject { described_class.new }
    its(:form_class) { is_expected.to eq(::BatchEditForm) }
  end

  describe "#update" do
    let(:work1) { create(:private_work, depositor: user.login) }
    let(:work2) { create(:private_work, depositor: user.login) }
    let(:work3) { create(:public_work,  depositor: user.login) }

    before { request.env["HTTP_REFERER"] = "where_i_came_from" }

    context "when changing visibility" do
      let(:parameters) do
        {
          update_type:        "update",
          batch_edit_item:    { visibility: "authenticated" },
          batch_document_ids: [work1.id, work2.id]
        }
      end

      it "applies the new setting to all works" do
        expect(VisibilityCopyJob).to receive(:perform_later).twice
        expect(InheritPermissionsJob).not_to receive(:perform_later)
        put :update, parameters.as_json
        expect(work1.reload.visibility).to eq("authenticated")
        expect(work2.reload.visibility).to eq("authenticated")
      end
    end

    context "when visibility is nil" do
      let(:parameters) do
        {
          update_type:        "update",
          batch_edit_item:    {},
          batch_document_ids: [work1.id, work3.id]
        }
      end

      it "preserves the objects' original permissions" do
        expect(VisibilityCopyJob).not_to receive(:perform_later)
        expect(InheritPermissionsJob).not_to receive(:perform_later)
        put :update, parameters.as_json
        expect(work1.reload.visibility).to eq("restricted")
        expect(work3.reload.visibility).to eq("open")
      end
    end

    context "when visibility is unchanged" do
      let(:parameters) do
        {
          update_type:        "update",
          batch_edit_item:    { visibility: "restricted" },
          batch_document_ids: [work1.id, work2.id]
        }
      end

      it "preserves the objects' original permissions" do
        expect(VisibilityCopyJob).not_to receive(:perform_later)
        expect(InheritPermissionsJob).not_to receive(:perform_later)
        put :update, parameters.as_json
        expect(work1.reload.visibility).to eq("restricted")
        expect(work2.reload.visibility).to eq("restricted")
      end
    end

    context "when permissions are changed" do
      let(:group_permission) { { "0" => { type: "group", name: "newgroop", access: "edit" } } }
      let(:parameters) do
        {
          update_type:        "update",
          batch_edit_item:    { permissions_attributes: group_permission },
          batch_document_ids: [work1.id, work2.id]
        }
      end

      it "updates the permissions on all the works" do
        expect(VisibilityCopyJob).not_to receive(:perform_later)
        expect(InheritPermissionsJob).to receive(:perform_later).twice
        put :update, parameters.as_json
        expect(work1.reload.edit_groups).to contain_exactly("newgroop")
        expect(work2.reload.edit_groups).to contain_exactly("newgroop")
      end
    end
  end
end
