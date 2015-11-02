require 'spec_helper'

describe NameDisambiguationService do
  subject { described_class.new(name).disambiguate }
  before do
    allow(User).to receive(:directory_attributes).with(name, [:uid, :givenname, :sn, :mail, :eduPersonPrimaryAffiliation]).and_return([])
    expect(User).not_to receive(:get_users)
  end

  context "when we have a normal name" do
    let(:name) { "Thompson, Britta M" }
    it "finds the user" do
      expect(User).to receive(:query_ldap_by_name).with("Britta M", "Thompson").and_return([{ id: "bmt13", given_name: "BRITTA MAY", surname: "THOMPSON", email: "bmt13@psu.edu", affiliation: ["FACULTY"] }])
      expect(subject.count).to eq(1)
    end
  end

  context "when we have an id" do
    let(:name) { "cam156" }
    it "finds the ids" do
      expect(User).to receive(:directory_attributes).with(name, [:uid, :givenname, :sn, :mail, :eduPersonPrimaryAffiliation]).and_return([{ uid: ["cam156"], givenname: ["CAROLYN A"], sn: ["COLE"], mail: ["cam156@psu.edu"], eduPersonPrimaryAffiliation: ["STAFF"] }])
      expect(User).not_to receive(:query_ldap_by_name)
      expect(subject.count).to eq(1)
    end
  end

  context "when we have multiple combined with an and" do
    let(:name) { "Carolyn Cole and Adam Wead" }
    it "finds both users" do
      expect(User).to receive(:query_ldap_by_name).with("Carolyn", "Cole").and_return([{ id: "cam156", given_name: "CAROLYN A", surname: "COLE", email: "cam156@psu.edu", affiliation: ["STAFF"] }])
      expect(User).to receive(:query_ldap_by_name).with("Adam", "Wead").and_return([{ id: "agw13", given_name: "ADAM GARNER", surname: "WEAD", email: "agw13@psu.edu", affiliation: ["STAFF"] }])
      is_expected.to eq([{ id: "cam156", given_name: "CAROLYN A", surname: "COLE", email: "cam156@psu.edu", affiliation: ["STAFF"] },
                            { id: "agw13", given_name: "ADAM GARNER", surname: "WEAD", email: "agw13@psu.edu", affiliation: ["STAFF"] }])
    end
  end

  context "when we have initials for first name" do
    let(:name) { "M.L. Ostrowski" }
    it "finds the user" do
      expect(User).to receive(:query_ldap_by_name).with("M L", "Ostrowski").and_return([{:id=>"mlo10", :given_name=>"MONA LEE", :surname=>"OSTROWSKI", :email=>"mlo10@psu.edu", :affiliation=>["STAFF"]}])
      is_expected.to eq([{ id: "mlo10", given_name: "MONA LEE", surname: "OSTROWSKI", email: "mlo10@psu.edu", affiliation: ["STAFF"] }])
    end
  end

  context "when we have multiple results" do
    let(:name) { "Jane Doe" }
    it "finds the user" do
      expect(User).to receive(:query_ldap_by_name).and_return([{:id=>"jjd1", :given_name=>"Jane", :surname=>"Doe", :email=>"jjd1@psu.edu", :affiliation=>["STAFF"]},{:id=>"jod1", :given_name=>"Jane Other", :surname=>"Doe", :email=>"jod1@psu.edu", :affiliation=>["STAFF"]}])
      is_expected.to eq([])
    end
  end

  context "when the user has many titles" do
    let(:name) { "Nicole Seger, MSN, RN, CPN" }
    it "finds the user" do
      expect(User).to receive(:query_ldap_by_name).with("MSN", "Nicole Seger").and_return([])
      expect(User).to receive(:query_ldap_by_name).with("Nicole Seger, MSN,", "RN, CPN").and_return([])
      expect(User).to receive(:query_ldap_by_name).with("Nicole", "Seger").and_return([{:id=>"nas150", :given_name=>"NICOLE A", :surname=>"SEGER", :email=>"nas150@psu.edu", :affiliation=>["STAFF"]}])
      is_expected.to eq([{ id: "nas150", given_name: "NICOLE A", surname: "SEGER", email: "nas150@psu.edu", affiliation: ["STAFF"] }])
    end
  end

  context "when the user has a title first" do
    let (:name) { "MSN Deb Cardenas" }
    it "finds the user" do
      expect(User).to receive(:query_ldap_by_name).with("MSN Deb", "Cardenas").and_return([])
      expect(User).to receive(:query_ldap_by_name).with("Deb", "Cardenas").and_return([{:id=>"dac40", :given_name=>"DEBORAH A.", :surname=>"CARDENAS", :email=>"dac40@psu.edu", :affiliation=>["STAFF"]}])
      is_expected.to eq([{ id: "dac40", given_name: "DEBORAH A.", surname: "CARDENAS", email: "dac40@psu.edu", affiliation: ["STAFF"] }])
    end
  end

  context "when the user has strange characters" do
    let (:name) { "Patricia Hswe *" }
    it "cleans the name" do
      expect(User).to receive(:query_ldap_by_name).with("Patricia", "Hswe").and_return([{:id=>"pmh22", :given_name=>"PATRICIA M", :surname=>"HSWE", :email=>"pmh22@psu.edu", :affiliation=>["FACULTY"]}])
      is_expected.to eq([{ id: "pmh22", given_name: "PATRICIA M", surname: "HSWE", email: "pmh22@psu.edu", affiliation: ["FACULTY"] }])
    end
  end

  context "when the user has an apostrophy" do
    let (:name) { "Anthony R. D'Augelli" }
    it "finds the user" do
      expect(User).to receive(:query_ldap_by_name).with("Anthony R", "D'Augelli").and_return([{ id: "ard", given_name: "ANTHONY RAYMOND", surname: "D'AUGELLI", email: "ard@psu.edu", affiliation: ["FACULTY"] }])
      is_expected.to eq([{ id: "ard", given_name: "ANTHONY RAYMOND", surname: "D'AUGELLI", email: "ard@psu.edu", affiliation: ["FACULTY"] }])
    end
  end

  context "when the user has many names" do
    let(:name) { "ALIDA HEATHER DOHN ROSS" }
    it "finds the user" do
      expect(User).to receive(:query_ldap_by_name).with("ALIDA HEATHER DOHN", "ROSS").and_return([])
      expect(User).to receive(:query_ldap_by_name).with("DOHN", "ROSS").and_return([])
      expect(User).to receive(:query_ldap_by_name).with("ALIDA HEATHER", "DOHN ROSS").and_return([{:id=>"hdr10", :given_name=>"ALIDA HEATHER", :surname=>"DOHN ROSS", :email=>"hdr10@psu.edu", :affiliation=>["STAFF"]}])
      is_expected.to eq([{ id: "hdr10", given_name: "ALIDA HEATHER", surname: "DOHN ROSS", email: "hdr10@psu.edu", affiliation: ["STAFF"] }])
    end
  end

  context "when the user has additional information" do
    let(:name) { "Cole, Carolyn (Kubicki Group)" }
    it "cleans the name" do
      expect(User).to receive(:query_ldap_by_name).with("Carolyn", "Cole").and_return([{:id=>"cam156", :given_name=>"CAROLYN A", :surname=>"COLE", :email=>"cam156@psu.edu", :affiliation=>["STAFF"]}])
      is_expected.to eq([{ id: "cam156", given_name: "CAROLYN A", surname: "COLE", email: "cam156@psu.edu", affiliation: ["STAFF"] }])
    end
  end

  context "when the user has an email in thier name" do
    context "when the email is not their id" do
      let(:name) { "Barbara I. Dewey a bdewey@psu.edu" }
      it "does not find the user" do
        expect(User).to receive(:directory_attributes).with("bdewey", [:uid, :givenname, :sn, :mail, :eduPersonPrimaryAffiliation]).and_return([])
        is_expected.to eq([{ id: "", given_name: "", surname: "", email: "bdewey@psu.edu", affiliation: [] }])
      end
    end

    context "when the email is their id" do
      let(:name) { "sjs230@psu.edu" }
      it "finds the user" do
        expect(User).to receive(:directory_attributes).with("sjs230", [:uid, :givenname, :sn, :mail, :eduPersonPrimaryAffiliation]).and_return([{ uid: ["sjs230"], givenname: ["SARAH J"], sn: ["STAGER"], mail: ["sjs230@psu.edu"], eduPersonPrimaryAffiliation: ["STAFF"] }])
        expect(subject.count).to eq(1)
      end
    end

    context "when the email is their id" do
      let(:name) { "sjs230@psu.edu, cam156@psu.edu" }
      it "finds the user" do
        expect(User).to receive(:directory_attributes).with("sjs230", [:uid, :givenname, :sn, :mail, :eduPersonPrimaryAffiliation]).and_return([{ uid: ["sjs230"], givenname: ["SARAH J"], sn: ["STAGER"], mail: ["sjs230@psu.edu"], eduPersonPrimaryAffiliation: ["STAFF"] }])
        expect(User).to receive(:directory_attributes).with("cam156", [:uid, :givenname, :sn, :mail, :eduPersonPrimaryAffiliation]).and_return([{ uid: ["cam156"], givenname: ["CAROLYN A"], sn: ["cole"], mail: ["cam156@psu.edu"], eduPersonPrimaryAffiliation: ["STAFF"] }])
        expect(subject.count).to eq(2)
      end
    end
  end
end
