require 'spec_helper'

describe GenericFileToShareJSONService do
  let(:name_service) { double }
  before do
    allow_any_instance_of(GenericFile).to receive(:current_host).and_return("https://scholarsphere.psu.edu")
    allow(NameDisambiguationService).to receive(:new).with(creator).and_return(name_service)
  end
  context "when checking the fixture file" do
    let(:file) { GenericFile.new(id: "x346f017s", title: ["Set9 ShamR 1.tif"], creator: ["Santy, Lorraine C"], date_modified: DateTime.parse("2015-07-30T20:15:08.528+00:00")) }
    let(:json) { JSON.parse(File.open(fixture_path + '/ss-share.json', 'rb').read) }
    let(:creator) { 'Santy, Lorraine C' }
    it "generates valid json" do
      expect(name_service).to receive(:disambiguate).and_return([{ email: "lcs13@psu.edu" }])
      expect(JSON.parse(described_class.new(file).json)).to eq(json)
    end
  end

  context "when checking any file" do
    let(:json_template) do
      "{
        \"jsonData\": {
          \"title\": \"#{title}\",
          \"contributors\": [{
              \"name\": \"#{creator}\",
              \"email\": \"#{creator_email}\"
            }],
          \"uris\": {
            \"canonicalUri\": \"https://scholarsphere.psu.edu/files/#{id}\",
            \"providerUris\": [ \"https://scholarsphere.psu.edu/files/#{id}\" ]
          },
          \"providerUpdatedDateTime\": \"#{date_uploaded}\"
        }
      }"
    end
    let(:json)    { JSON.parse(json_template) }
    let(:file)    { GenericFile.new(id: id, title: [title], creator: [creator], date_modified: DateTime.parse(date_uploaded)) }
    let(:title)   { "abc123" }
    let(:id) { 'zzzzz' }
    let(:date_uploaded) { "2015-07-30T20:15:08Z" }
    subject { JSON.parse(described_class.new(file).json) }

    context "when the creator exists in ldap" do
      let(:creator) { ' Cole, Carolyn Ann' }
      let(:creator_email) { 'cam156@psu.edu' }
      it "formats the json" do
        expect(name_service).to receive(:disambiguate).and_return([{ email: creator_email }])
        is_expected.to eq(json)
      end
    end

    context "when the creator does not exist in ldap" do
      let(:creator) { ' Frog, Kermit The' }
      let(:creator_email) {}
      it "formats the json" do
        expect(name_service).to receive(:disambiguate).and_return([])
        is_expected.to eq(json)
      end
    end
  end
end
