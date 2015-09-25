require 'spec_helper'

describe User, type: :model do
  let(:user)        { FactoryGirl.find_or_create(:jill) }
  let(:empty_user)  { described_class.new }

  it "has a login" do
    expect(user.login).to eq("jilluser")
  end
  it "redefines to_param to make redis keys more recognizable" do
    expect(user.to_param).to eq(user.login)
  end
  describe "#groups" do
    describe "valid user" do
      before do
        filter = Net::LDAP::Filter.eq('uid', user.login)
        expect(Hydra::LDAP).to receive(:groups_for_user).with(filter).and_return(["umg/up.dlt.gamma-ci", "umg/up.dlt.redmine"])
        allow(Hydra::LDAP.connection).to receive(:get_operation_result).and_return(OpenStruct.new(code: 0, message: "Success"))
      end
      it "returns a list" do
        expect(user.groups).to eq(["umg/up.dlt.gamma-ci", "umg/up.dlt.redmine"])
      end
    end
    describe "empty user" do
      before do
        expect(Hydra::LDAP).to receive(:groups_for_user).never
        expect(Hydra::LDAP.connection).to receive(:get_operation_result).never
      end
      it "returns a list" do
        expect(empty_user.groups).to eq([])
      end
    end
  end
  describe "#ldap_exist?" do
    describe "valid user" do
      before do
        filter = Net::LDAP::Filter.eq('uid', user.login)
        expect(Hydra::LDAP).to receive(:does_user_exist?).with(filter).and_return(true)
        allow(Hydra::LDAP.connection).to receive(:get_operation_result).and_return(OpenStruct.new(code: 0, message: "Success"))
      end
      it "returns a list" do
        expect(user.ldap_exist?).to eq(true)
      end
    end
    describe "empty user" do
      before do
        expect(Hydra::LDAP).to receive(:does_user_exist?).never
        expect(Hydra::LDAP.connection).to receive(:get_operation_result).never
      end
      it "returns a list" do
        expect(empty_user.ldap_exist?).to eq(false)
      end
    end
    describe "LDAP miss behaves" do
      before do
        Sufia.config.retry_unless_sleep = 0.01
        filter = Net::LDAP::Filter.eq('uid', user.login)
        allow(Hydra::LDAP).to receive(:does_user_exist?).twice.with(filter).and_return(true)
        # get unwilling the first run through
        expect(Hydra::LDAP.connection).to receive(:get_operation_result).once.and_return(OpenStruct.new(code: 53, message: "Unwilling"))
        # get success the second run through which is two calls and one more in the main code
        expect(Hydra::LDAP.connection).to receive(:get_operation_result).twice.and_return(OpenStruct.new(code: 0, message: "sucess"))
      end
      #
      it "returns true after failing and sleeping once" do
        expect(described_class).to receive(:sleep).with(0.01)
        expect(user.ldap_exist?).to eq(true)
      end
      #
    end
  end

  describe "#directory_attributes" do
    before do
      entry = Net::LDAP::Entry.new
      entry['dn'] = ["uid=mjg36,dc=psu,edu"]
      entry['cn'] = ["MICHAEL JOSEPH GIARLO"]
      expect(Hydra::LDAP).to receive(:get_user).and_return([entry])
    end
    it "returns user attributes from LDAP" do
      expect(described_class.directory_attributes('mjg36', ['cn']).first['cn']).to eq(['MICHAEL JOSEPH GIARLO'])
    end
  end

  describe "#query_ldap_by_name_or_id" do
    let(:name_part) { "cam" }
    let(:filter) { Net::LDAP::Filter.construct("(& (| (uid=#{name_part}* ) (givenname=#{name_part}*) (sn=#{name_part}*)) (| (eduPersonPrimaryAffiliation=STUDENT) (eduPersonPrimaryAffiliation=FACULTY) (eduPersonPrimaryAffiliation=STAFF) (eduPersonPrimaryAffiliation=EMPLOYEE))))") }
    let(:results) {[Net::LDAP::Entry.new("uid=cac6094,dc=psu,dc=edu").tap { |e| e[:uid] = ["cac6094"]; e[:displayname] = ["CAMILO CAPURRO"] },
                    Net::LDAP::Entry.new("uid=csl5210,dc=psu,dc=edu").tap { |e| e[:uid] = ["csl5210"]; e[:displayname] = ["CAMERON SIERRA LANGSJOEN"] },
                    Net::LDAP::Entry.new("uid=cnt5046,dc=psu,dc=edu").tap { |e| e[:uid] = ["cnt5046"]; e[:displayname] = ["CAMILLE NAKIA TINDAL"] }
                   ]}
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
    subject { described_class.from_url_component("cam") }

    context "when user exists" do
      before do
        entry = Net::LDAP::Entry.new
        entry['dn'] = ["uid=mjg36,dc=psu,edu"]
        entry['cn'] = ["MICHAEL JOSEPH GIARLO"]
        entry['displayname'] = ["John Smith"]
        entry['psofficelocation'] = ["Beaver Stadium$Seat 100"]
        allow(Hydra::LDAP).to receive(:get_user).and_return([entry])
        allow(Hydra::LDAP).to receive(:does_user_exist?).and_return(true)
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
      before do
        allow(Hydra::LDAP).to receive(:does_user_exist?).and_return(false)
      end

      it "does not create a user" do
        expect(described_class.count).to eq 0
        is_expected.to_not be_a_kind_of(described_class)
        expect(described_class.count).to eq 0
      end
    end
  end
end
