require 'spec_helper'

describe 'host_to_vhost' do
  it "should return the proper vhost on ss2test" do
    Socket.stub(:gethostname).and_return('ss2test')
    Rails.application.get_vhost_by_host[0].should == 'scholarsphere-test.dlt.psu.edu'
    Rails.application.get_vhost_by_host[1].should == 'https://scholarsphere-test.dlt.psu.edu/'
  end
  it "should return the proper vhost on ss1demo" do
    Socket.stub(:gethostname).and_return('ss1demo')
    Rails.application.get_vhost_by_host[0].should == 'scholarsphere-demo.dlt.psu.edu'
    Rails.application.get_vhost_by_host[1].should == 'https://scholarsphere-demo.dlt.psu.edu/'
  end
  it "should return the proper vhost on ss1qa" do
    Socket.stub(:gethostname).and_return('ss1qa')
    Rails.application.get_vhost_by_host[0].should == 'scholarsphere-qa.dlt.psu.edu'
    Rails.application.get_vhost_by_host[1].should == 'https://scholarsphere-qa.dlt.psu.edu/'
  end
  it "should return the proper vhost on ss1stage" do
    Socket.stub(:gethostname).and_return('ss1stage')
    Rails.application.get_vhost_by_host[0].should == 'scholarsphere-staging.dlt.psu.edu'
    Rails.application.get_vhost_by_host[1].should == 'https://scholarsphere-staging.dlt.psu.edu/'
  end
  it "should return the proper vhost on ss1prod" do
    Socket.stub(:gethostname).and_return('ss1prod')
    Rails.application.get_vhost_by_host[0].should == 'scholarsphere.psu.edu'
    Rails.application.get_vhost_by_host[1].should == 'https://scholarsphere.psu.edu/'
  end
  it "should return the proper vhost on dev" do
    Socket.stub(:gethostname).and_return('some1host')
    Rails.application.get_vhost_by_host[0].should == 'some1host'
    Rails.application.get_vhost_by_host[1].should == 'https://some1host/'
  end
end
