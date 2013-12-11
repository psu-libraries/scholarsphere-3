require 'spec_helper'

describe Devise::Strategies::HttpHeaderAuthenticatable do
  subject {Devise::Strategies::HttpHeaderAuthenticatable.new(nil)}
  describe "when REMOTE_USER present" do
    let(:headers) {{"REMOTE_USER"=>"abc123"} }
    before do
      # I do this in before block or right before test executes
      @request = double(:request)
      @request.should_receive(:headers).and_return(headers)
      subject.should_receive(:request).and_return(@request)
    end
    it "is valid" do
      subject.valid?.should == true
    end
  end

  describe "when REMOTE_USER is not present" do
    let(:headers) {{}}
    before do
      # I do this in before block or right before test executes
      @request = double(:request)
      @request.should_receive(:headers).and_return(headers)
      subject.should_receive(:request).and_return(@request)
    end
    it "is valid" do
      subject.valid?.should == false
    end
  end

end
