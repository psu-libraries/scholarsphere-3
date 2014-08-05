require 'spec_helper'

describe Blacklight do
  it "reminds us to remove unneeded fixes" do
    expect(Blacklight::VERSION).to eq("5.5.2"), "The Blacklight version has changed. If the new version includes PR #960 (https://github.com/projectblacklight/blacklight/pull/960), we can remove the css in app/assets/stylesheets/blacklight-fix.css.scss and this test"
  end
end
