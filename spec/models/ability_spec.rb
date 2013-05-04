require 'spec_helper'
require "cancan/matchers"

describe Ability do
  after(:all) do
    GenericFile.destroy_all
  end
  describe "a user" do
    let (:sender) { FactoryGirl.create(:test_user_1) }
    let (:user) { FactoryGirl.create(:user) }
    let (:file) do
      GenericFile.new.tap do|file|
        file.apply_depositor_metadata(sender.user_key)
        file.save!
      end
    end
    subject { Ability.new(user)}
    it {should be_able_to(:create, ProxyDepositRequest)}

    context "with a ProxyDepositRequest that they receive" do
      let (:request) { ProxyDepositRequest.create!(pid: file.pid, receiving_user: user, sending_user: sender) }
      it { should be_able_to(:accept, request) }
      it { should be_able_to(:reject, request) }
      it { should_not be_able_to(:destroy, request) }

      context "and the request has already been accepted" do
        let (:request) { ProxyDepositRequest.create!(pid: file.pid, receiving_user: user, sending_user: sender, status: 'accepted') }
        it { should_not be_able_to(:accept, request) }
        it { should_not be_able_to(:reject, request) }
        it { should_not be_able_to(:destroy, request) }
      end
    end

    context "with a ProxyDepositRequest they are the sender of" do
      let (:request) { ProxyDepositRequest.create!(pid: file.pid, receiving_user: sender, sending_user: user) }
      it { should_not be_able_to(:accept, request) }
      it { should_not be_able_to(:reject, request) }
      it { should be_able_to(:destroy, request) }

      context "and the request has already been accepted" do
        let (:request) { ProxyDepositRequest.create!(pid: file.pid, receiving_user: sender, sending_user: user, status: 'accepted') }
        it { should_not be_able_to(:accept, request) }
        it { should_not be_able_to(:reject, request) }
        it { should_not be_able_to(:destroy, request) }
      end
    end
  end
end
