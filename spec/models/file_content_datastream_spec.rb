# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe FileContentDatastream do
  before do
    GenericFile.any_instance.stub(:terms_of_service).and_return('1')
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
      doc.root.xpath('//ns:imageWidth/text()', {'ns'=>'http://hul.harvard.edu/ois/xml/ns/fits/fits_output'}).inner_text.should == '50'
    end
  end
end
