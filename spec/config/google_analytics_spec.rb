require 'spec_helper'

describe Rails.application do
  it 'should respond to google_analytics_id' do
    subject.should respond_to(:google_analytics_id)
  end
  it 'should have the proper google analytics id' do
    Socket.stub(:gethostname).and_return('ss1prod')
    subject.google_analytics_id.should == 'UA-33252017-2'
  end
end
