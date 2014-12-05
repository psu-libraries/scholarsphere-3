require 'spec_helper'

describe FileContentDatastream, :type => :model do
  before do
    allow_any_instance_of(GenericFile).to receive(:terms_of_service).and_return('1')
    @subject = FileContentDatastream.new(nil, 'content')
    @subject.stub(pid:'my_pid')
    @subject.stub(dsVersionID:'content.7')
  end
  describe "extract_metadata" do
    it "should return an xml document" do
      repo = double("repo")
      repo.stub(config:{})
      f = File.new(Rails.root + 'spec/fixtures/world.png')
      content = double("file")
      content.stub(read:f.read)
      content.stub(rewind:f.rewind)
      @subject.stub(content: f)
      xml = @subject.extract_metadata
      doc = Nokogiri::XML.parse(xml)
      expect(doc.root.xpath('//ns:imageWidth/text()', {'ns'=>'http://hul.harvard.edu/ois/xml/ns/fits/fits_output'}).inner_text).to eq('50')
    end
  end
end
