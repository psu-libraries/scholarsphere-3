require 'spec_helper'

describe User, :type => :model do
  before(:each) do
    @user = FactoryGirl.find_or_create(:jill)
    @another_user = FactoryGirl.find_or_create(:archivist)
  end
  it "should have a login" do
    expect(@user.login).to eq("jilluser")
  end
  it "should redefine to_param to make redis keys more recognizable" do
    expect(@user.to_param).to eq(@user.login)
  end
  describe "#groups" do
    describe "valid user" do
      before do
        filter = Net::LDAP::Filter.eq('uid', @user.login)
        expect(Hydra::LDAP).to receive(:groups_for_user).with(filter).and_return(["umg/up.dlt.gamma-ci", "umg/up.dlt.redmine"])
        allow(Hydra::LDAP.connection).to receive(:get_operation_result).and_return(OpenStruct.new({code:0, message:"Success"}))
      end
      it "should return a list" do
        expect(@user.groups).to eq(["umg/up.dlt.gamma-ci", "umg/up.dlt.redmine"])
      end
    end
    describe "empty user" do
      before do
        expect(Hydra::LDAP).to receive(:groups_for_user).never
        expect(Hydra::LDAP.connection).to receive(:get_operation_result).never
      end
      it "should return a list" do
        u = User.new
        expect(u.groups).to eq([])
      end
    end
  end
  describe "#ldap_exist?" do
    describe "valid user" do
      before do
        filter = Net::LDAP::Filter.eq('uid', @user.login)
        expect(Hydra::LDAP).to receive(:does_user_exist?).with(filter).and_return(true)
        allow(Hydra::LDAP.connection).to receive(:get_operation_result).and_return(OpenStruct.new({code:0, message:"Success"}))
      end
      it "should return a list" do
        expect(@user.ldap_exist?).to eq(true)
      end
    end
    describe "empty user" do
      before do
        expect(Hydra::LDAP).to receive(:does_user_exist?).never
        expect(Hydra::LDAP.connection).to receive(:get_operation_result).never
      end
      it "should return a list" do
        u = User.new
        expect(u.ldap_exist?).to eq(false)
      end
    end
  end

  describe "#directory_attributes" do
    before do
      entry = Net::LDAP::Entry.new()
      entry['dn'] = ["uid=mjg36,dc=psu,edu"]
      entry['cn'] = ["MICHAEL JOSEPH GIARLO"]
      expect(Hydra::LDAP).to receive(:get_user).and_return([entry])
    end
    it "should return user attributes from LDAP" do
      expect(User.directory_attributes('mjg36', ['cn']).first['cn']).to eq(['MICHAEL JOSEPH GIARLO'])
    end
  end

  describe "#query_ldap_by_name_or_id" do
    let(:name_part) {"cam"}
    let(:filter) {Net::LDAP::Filter.construct("(& (| (uid=#{name_part}* ) (givenname=#{name_part}*) (sn=#{name_part}*)) (| (eduPersonPrimaryAffiliation=STUDENT) (eduPersonPrimaryAffiliation=FACULTY) (eduPersonPrimaryAffiliation=STAFF) (eduPersonPrimaryAffiliation=EMPLOYEE))))")}
    let(:results) {[Net::LDAP::Entry.new("uid=cac6094,dc=psu,dc=edu").tap {|e| e[:uid]=["cac6094"]; e[:displayname]=["CAMILO CAPURRO"]},
                    Net::LDAP::Entry.new("uid=csl5210,dc=psu,dc=edu").tap {|e| e[:uid]=["csl5210"]; e[:displayname]=["CAMERON SIERRA LANGSJOEN"]},
                    Net::LDAP::Entry.new("uid=cnt5046,dc=psu,dc=edu").tap {|e| e[:uid]=["cnt5046"]; e[:displayname]=["CAMILLE NAKIA TINDAL"]}
                  ]}
    let(:attrs) { ["uid", "displayname"]}

    before do
      Hydra::LDAP.should_receive(:get_user).with(filter, attrs).and_return(results)
      Hydra::LDAP.connection.stub(:get_operation_result).and_return(OpenStruct.new({code:0, message:"Success"}))
    end
    it "should return a list or people" do
      expect(User.query_ldap_by_name_or_id("cam")).to eq([{id:"cac6094", text:"CAMILO CAPURRO (cac6094)"},
                                                     {id:"csl5210", text:"CAMERON SIERRA LANGSJOEN (csl5210)"},
                                                     {id:"cnt5046", text:"CAMILLE NAKIA TINDAL (cnt5046)"}
                                                    ])
    end
  end
end
