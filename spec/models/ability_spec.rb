require 'spec_helper'
require "cancan/matchers"

describe Ability do
  describe "a user" do
    let (:user) { FactoryGirl.create(:user) }
    subject { Ability.new(user)}
    context "with a file" do
      let (:file) do
        GenericFile.new.tap do|file|
          file.apply_depositor_metadata('foo')
          file.save!
        end
      end
      context "and with a proxy_deposit_request" do
        before do
          ProxyDepositRequest.create!(pid: file.pid, receiving_user: user, sending_user: 'foo')
        end
        it { should be_able_to(:proxy, file) }
      end 
      it { should_not be_able_to(:proxy, file) }
    end
  end
end
