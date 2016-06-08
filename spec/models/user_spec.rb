# frozen_string_literal: true
require 'spec_helper'
require "cancan/matchers"

describe User, type: :model do
  let(:user) { create(:ldap_jill) }

  it "has a login" do
    expect(user.login).to eq("jilluser")
  end
  it "redefines to_param to make redis keys more recognizable" do
    expect(user.to_param).to eq(user.login)
  end
  describe "#ldap_exist?" do
    subject { user.ldap_exist? }
    context "when the user exists" do
      before { allow(LdapUser).to receive(:check_ldap_exist!).and_return(true) }
      it { is_expected.to be true }
    end
    context "when the user does not exist" do
      before { allow(LdapUser).to receive(:check_ldap_exist!).and_return(false) }
      it { is_expected.to be false }
    end
    context "when LDAP misbehaves" do
      before do
        filter = Net::LDAP::Filter.eq('uid', user.login)
        allow(Hydra::LDAP).to receive(:does_user_exist?).twice.with(filter).and_return(true)
      end

      it "returns true after LDAP returns 'unwilling' first, then sleeps and returns true on the second call" do
        expect(Hydra::LDAP.connection).to receive(:get_operation_result).once.and_return(OpenStruct.new(code: 53, message: "Unwilling"))
        expect(Hydra::LDAP.connection).to receive(:get_operation_result).once.and_return(OpenStruct.new(code: 0, message: "sucess"))
        expect(LdapUser).to receive(:sleep).with(Rails.application.config.ldap_unwilling_sleep)
        expect(user.ldap_exist?).to eq(true)
      end
    end
  end

  describe "#directory_attributes" do
    let(:entry) { build(:ldap_entry, uid: "mjg36", cn: "MICHAEL JOSEPH GIARLO") }
    before { expect(Hydra::LDAP).to receive(:get_user).and_return([entry]) }
    it "returns user attributes from LDAP" do
      expect(described_class.directory_attributes('mjg36', ['cn']).first['cn']).to eq(['MICHAEL JOSEPH GIARLO'])
    end
  end

  describe "#query_ldap_by_name_or_id" do
    let(:name_part) { "cam" }
    let(:filter) { Net::LDAP::Filter.construct("(& (| (uid=#{name_part}* ) (givenname=#{name_part}*) (sn=#{name_part}*)) (| (eduPersonPrimaryAffiliation=STUDENT) (eduPersonPrimaryAffiliation=FACULTY) (eduPersonPrimaryAffiliation=STAFF) (eduPersonPrimaryAffiliation=EMPLOYEE))))") }
    let(:results) do
      [
        build(:ldap_entry, uid: "cac6094", displayname: "CAMILO CAPURRO"),
        build(:ldap_entry, uid: "csl5210", displayname: "CAMERON SIERRA LANGSJOEN"),
        build(:ldap_entry, uid: "cnt5046", displayname: "CAMILLE NAKIA TINDAL")
      ]
    end
    let(:attrs) { ["uid", "displayname"] }

    before do
      expect(Hydra::LDAP).to receive(:get_user).with(filter, attrs).and_return(results)
      allow(Hydra::LDAP.connection).to receive(:get_operation_result).and_return(OpenStruct.new(code: 0, message: "Success"))
    end
    it "returns a list or people" do
      expect(described_class.query_ldap_by_name_or_id("cam")).to eq([{ id: "cac6094", text: "CAMILO CAPURRO (cac6094)" },
                                                                     { id: "csl5210", text: "CAMERON SIERRA LANGSJOEN (csl5210)" },
                                                                     { id: "cnt5046", text: "CAMILLE NAKIA TINDAL (cnt5046)" }
                                                                    ])
    end
  end

  describe "#from_url_component" do
    let(:entry) do
      build(:ldap_entry, uid: 'mjg36', cn: "MICHAEL JOSEPH GIARLO", displayname: "John Smith", psofficelocation: "Beaver Stadium$Seat 100")
    end
    subject { described_class.from_url_component("cam") }

    context "when user exists" do
      before do
        allow(LdapUser).to receive(:check_ldap_exist!).and_return(true)
        allow(LdapUser).to receive(:group_response_from_ldap).and_return([])
        allow(Hydra::LDAP).to receive(:get_user).and_return([entry])
      end

      it "creates a user" do
        expect(described_class.count).to eq 0
        is_expected.to be_a_kind_of(described_class)
        expect(subject.display_name).to eq "John Smith"
        expect(subject.office).to eq "Beaver Stadium\nSeat 100"
        expect(subject.website).to be_nil
        expect(subject.title).to be_nil
        expect(described_class.count).to eq 1
      end
    end

    context "user does not exists" do
      before { allow(Hydra::LDAP).to receive(:does_user_exist?).and_return(false) }

      it "does not create a user" do
        expect(described_class.count).to eq 0
        is_expected.not_to be_a_kind_of(described_class)
        expect(described_class.count).to eq 0
      end
    end
  end

  describe "administrator?" do
    subject { user.administrator? }

    context "normal user" do
      let(:user) { create :user }
      it { is_expected.to be_falsey }
    end
    context "administrative user" do
      let(:user) { create :administrator }
      it { is_expected.to be_truthy }
    end
  end

  describe "file abilities" do
    let(:private_file) { create(:registered_file) }
    let(:my_file)      { create(:registered_file, depositor: user.login) }
    let(:shared_file)  { create(:registered_file, edit_users: [user.login]) }

    describe "abilities" do
      subject { Ability.new(user) }
      context "normal user" do
        let(:user) { create :user }

        it { should be_able_to(:edit, my_file) }
        it { should be_able_to(:edit, shared_file) }
        it { should_not be_able_to(:edit, private_file) }
      end

      context "administrative user" do
        let(:user) { create :administrator }

        it { should be_able_to(:edit, my_file) }
        it { should be_able_to(:edit, shared_file) }
        it { should be_able_to(:edit, private_file) }
      end
    end

    describe "administrating?" do
      subject { user.administrating?(file) }

      context "normal user" do
        let(:user) { create :user }
        context "user's file" do
          let(:file) { my_file }
          it { is_expected.to be_falsey }
        end
        context "private file" do
          let(:file) { private_file }
          it { is_expected.to be_falsey }
        end
        context "shared file" do
          let(:file) { shared_file }
          it { is_expected.to be_falsey }
        end
      end
      context "administrative user" do
        let(:user) { create :administrator }
        context "user's file" do
          let(:file) { my_file }
          it {
            pending("Why is this false?")
            is_expected.to be_falsey
          }
        end
        context "private file" do
          let(:file) { private_file }
          it { is_expected.to be_truthy }
        end
        context "shared file" do
          let(:file) { shared_file }
          it {
            pending("Why is this false?")
            is_expected.to be_falsey
          }
        end
      end
    end
  end
end
