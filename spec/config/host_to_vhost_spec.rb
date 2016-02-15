# frozen_string_literal: true
require 'spec_helper'

describe 'host_to_vhost' do
  it "returns the proper vhost on ss2test" do
    allow(Socket).to receive(:gethostname).and_return('ss2test')
    expect(Rails.application.get_vhost_by_host[0]).to eq('scholarsphere-test.dlt.psu.edu')
    expect(Rails.application.get_vhost_by_host[1]).to eq('https://scholarsphere-test.dlt.psu.edu/')
  end
  it "returns the proper vhost on ss1demo" do
    allow(Socket).to receive(:gethostname).and_return('ss1demo')
    expect(Rails.application.get_vhost_by_host[0]).to eq('scholarsphere-demo.dlt.psu.edu')
    expect(Rails.application.get_vhost_by_host[1]).to eq('https://scholarsphere-demo.dlt.psu.edu/')
  end
  it "returns the proper vhost on ss1qa" do
    allow(Socket).to receive(:gethostname).and_return('ss1qa')
    expect(Rails.application.get_vhost_by_host[0]).to eq('scholarsphere-qa.dlt.psu.edu')
    expect(Rails.application.get_vhost_by_host[1]).to eq('https://scholarsphere-qa.dlt.psu.edu/')
  end
  it "returns the proper vhost on ss1stage" do
    allow(Socket).to receive(:gethostname).and_return('ss1stage')
    expect(Rails.application.get_vhost_by_host[0]).to eq('scholarsphere-staging.dlt.psu.edu')
    expect(Rails.application.get_vhost_by_host[1]).to eq('https://scholarsphere-staging.dlt.psu.edu/')
  end
  it "returns the proper vhost on ss1prod" do
    allow(Socket).to receive(:gethostname).and_return('ss1prod')
    expect(Rails.application.get_vhost_by_host[0]).to eq('scholarsphere.psu.edu')
    expect(Rails.application.get_vhost_by_host[1]).to eq('https://scholarsphere.psu.edu/')
  end
  it "returns the proper vhost on dev" do
    allow(Socket).to receive(:gethostname).and_return('some1host')
    expect(Rails.application.get_vhost_by_host[0]).to eq('some1host')
    expect(Rails.application.get_vhost_by_host[1]).to eq('https://some1host/')
  end
end
