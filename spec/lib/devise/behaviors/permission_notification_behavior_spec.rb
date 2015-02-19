require 'spec_helper'
require 'i18n'

class NotifiableThing
  include Behaviors::PermissionsNotificationBehavior

  def evaluate(original_perm, new_perm)
    evaluate_permission_state(original_perm, new_perm)
  end

  def notify(state, generic_file)
    notify_users(state, generic_file)
  end

  def t(key, *args)
    I18n.t(key, *args)
  end
end

describe Behaviors::PermissionsNotificationBehavior do
  subject { NotifiableThing.new }
  describe "evaluate_permission_state" do
    let(:no_perm) { [] }
    let(:one_perm) { [{ name: "abd123", type: "person", access: "edit" }] }
    let(:multi_perm) { [{ name: "zzz123", type: "person", access: "edit" },{ name: "def123", type: "person", access: "edit" }] }

    context "no permissions after" do
      it "has nothing added or removed for no permissions before" do
        state = subject.evaluate(no_perm, no_perm)
        expect(state[:added]).to eq []
        expect(state[:removed]).to eq []
      end
      it "has permission removed for one permissions before" do
        state = subject.evaluate(one_perm, no_perm)
        expect(state[:added]).to eq []
        expect(state[:removed]).to eq one_perm
      end
      it "has permissions removed for multiple permissions before" do
        state = subject.evaluate(multi_perm, no_perm)
        expect(state[:added]).to eq []
        expect(state[:removed]).to eq multi_perm
      end
    end
    context "one permission after" do
      it "has nothing added or removed for one permission before" do
        state = subject.evaluate(one_perm, one_perm)
        expect(state[:added]).to eq []
        expect(state[:removed]).to eq []
      end
      it "has permission added for no permissions before" do
        state = subject.evaluate(no_perm, one_perm)
        expect(state[:added]).to eq one_perm
        expect(state[:removed]).to eq []
      end
      it "has permissions added and removed for multiple permissions before" do
        state = subject.evaluate(multi_perm,one_perm)
        expect(state[:added]).to eq one_perm
        expect(state[:removed]).to eq multi_perm
      end
    end
    context "multiple permissions after" do
      it "has nothing added or removed for multiple permissions before" do
        state = subject.evaluate(multi_perm, multi_perm)
        expect(state[:added]).to eq []
        expect(state[:removed]).to eq []
      end
      it "has permissions added for no permissions before" do
        state = subject.evaluate(no_perm, multi_perm)
        expect(state[:added]).to eq multi_perm
        expect(state[:removed]).to eq []
      end
      it "has permissions added and removed for no permissions before" do
        state = subject.evaluate(one_perm, multi_perm)
        expect(state[:added]).to eq multi_perm
        expect(state[:removed]).to eq one_perm
      end
    end
  end
  describe "notify_users" do
    let (:user)  { double('stubbed user') }
    let (:batch_user)  { double('stubbed batch_user') }
    let (:message) { "You can now edit file title" }
    let (:message_subject) { "Permission change notification" }
    let (:generic_file) { double('stubbed file') }

    before do
      allow(User).to receive(:find_by_user_key).and_return(user)
      allow(User).to receive(:batchuser).and_return(batch_user)
      allow(subject).to receive(:params).and_return({ action: "update" })
      allow(generic_file).to receive(:title).and_return("title")
    end

    context "permissions no change" do
      let (:state) { { added: [], removed: [] } }
      it "notifies no one" do
        expect(batch_user).not_to receive(:send_message)
        subject.notify(state, generic_file)
      end
    end
    context "permissions added" do
      let (:state){ { added: [{ name: "abd123", type: "person", access: "edit" }], removed: [] } }
      it "notifies one user added" do
        expect(batch_user).to receive(:send_message).with(user, message, message_subject)
        subject.notify(state, generic_file)
      end
    end
    context "permissions removed" do
      let (:state){ { added: [ ], removed: [{ name: "abd123", type: "person", access: "edit" }] } }
      it "notifies no one" do
        expect(batch_user).not_to receive(:send_message)
        subject.notify(state, generic_file)
      end
    end
  end
end
