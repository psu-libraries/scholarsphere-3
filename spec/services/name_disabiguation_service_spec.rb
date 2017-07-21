# frozen_string_literal: true
require "rails_helper"

describe NameDisambiguationService, unless: travis? do
  subject { described_class.new(name).disambiguate }

  context "when we have a normal name" do
    let(:name) { "Thompson, Britta M" }
    it "finds the user" do
      expect(subject).to eq([{ id: "bmt13", given_name: "BRITTA MAY", surname: "THOMPSON", email: "bmt13@psu.edu", affiliation: ["FACULTY"], displayname: "BRITTA MAY THOMPSON" }])
    end
  end

  context "when we have an id" do
    let(:name) { "cam156" }
    it "finds the ids" do
      expect(subject).to eq([{ id: "cam156", given_name: "CAROLYN ANN", surname: "COLE", email: "cam156@psu.edu", affiliation: ["STAFF"], displayname: "CAROLYN ANN COLE" }])
    end
  end

  context "when we have multiple combined with an and" do
    let(:name) { "Carolyn Cole and Adam Wead" }
    it "finds both users" do
      is_expected.to eq([{ id: "cam156", given_name: "CAROLYN ANN", surname: "COLE", email: "cam156@psu.edu", affiliation: ["STAFF"], displayname: "CAROLYN ANN COLE" },
                         { id: "agw13", given_name: "ADAM GARNER", surname: "WEAD", email: "agw13@psu.edu", affiliation: ["STAFF"], displayname: "ADAM GARNER WEAD" }])
    end
  end

  context "when we have initials for first name" do
    let(:name) { "K.B. Baker" }
    it "finds the user" do
      is_expected.to eq([{ id: "kbb2", given_name: "KURT BRADLEY", surname: "BAKER", email: "kbb2@psu.edu", affiliation: ["RETIREE"], displayname: "KURT BRADLEY BAKER" }])
    end
  end

  context "when we have multiple results" do
    let(:name) { "Jane Doe" }
    it "finds the user" do
      is_expected.to eq([])
    end
  end

  context "when the user has many titles" do
    let(:name) { "Nicole Seger, MSN, RN, CPN" }
    it "finds the user" do
      is_expected.to eq([{ id: "nas150", given_name: "NICOLE A", surname: "SEGER", email: "nas150@psu.edu", affiliation: ["STAFF"], displayname: "NICOLE A SEGER" }])
    end
  end

  context "when the user has a title first" do
    let(:name) { "MSN Deb Cardenas" }
    it "finds the user" do
      is_expected.to eq([{ id: "dac40", given_name: "DEBORAH A.", surname: "CARDENAS", email: "dac40@psu.edu", affiliation: ["STAFF"], displayname: "DEBORAH A. CARDENAS" }])
    end
  end

  context "when the user has strange characters" do
    let(:name) { "Patricia Hswe *" }
    it "cleans the name" do
      is_expected.to eq([{ id: "pmh22", given_name: "PATRICIA M", surname: "HSWE", email: "pmh22@psu.edu", affiliation: ["MEMBER"], displayname: "PATRICIA M HSWE" }])
    end
  end

  context "when the user has an apostrophy" do
    let(:name) { "Anthony R. D'Augelli" }
    it "finds the user" do
      is_expected.to eq([{ id: "ard", given_name: "ANTHONY RAYMOND", surname: "D'AUGELLI", email: "ard@psu.edu", affiliation: ["FACULTY"], displayname: "ANTHONY RAYMOND D'AUGELLI" }])
    end
  end

  context "when the user has many names" do
    let(:name) { "ALIDA HEATHER DOHN ROSS" }
    it "finds the user" do
      is_expected.to eq([{ id: "hdr10", given_name: "ALIDA HEATHER", surname: "DOHN ROSS", email: "hdr10@psu.edu", affiliation: ["STAFF"], displayname: "ALIDA HEATHER DOHN ROSS" }])
    end
  end

  context "when the user has additional information" do
    let(:name) { "Cole, Carolyn (Kubicki Group)" }
    it "cleans the name" do
      is_expected.to eq([{ id: "cam156", given_name: "CAROLYN ANN", surname: "COLE", email: "cam156@psu.edu", affiliation: ["STAFF"], displayname: "CAROLYN ANN COLE" }])
    end
  end

  context "when the user has an email in thier name" do
    context "when the email is not their id" do
      let(:name) { "Barbara I. Dewey a bdewey@psu.edu" }
      it "does not find the user" do
        is_expected.to eq([{ id: "bid1", given_name: "BARBARA IRENE", surname: "DEWEY", email: "bid1@psu.edu", affiliation: ["STAFF"], displayname: "BARBARA IRENE DEWEY" }])
      end
    end

    context "when the email is their id" do
      let(:name) { "sjs230@psu.edu" }
      it "finds the user" do
        expect(subject.count).to eq(1)
      end
    end

    context "when the email is their id" do
      let(:name) { "sjs230@psu.edu, cam156@psu.edu" }
      it "finds the user" do
        expect(subject.count).to eq(2)
      end
    end
  end
end
