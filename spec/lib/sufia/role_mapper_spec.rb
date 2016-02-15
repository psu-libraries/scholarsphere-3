# frozen_string_literal: true
require 'spec_helper'

describe RoleMapper do
  before do
    @user = FactoryGirl.find_or_create(:user)
    allow_any_instance_of(User).to receive(:groups).and_return(["umg/up.dlt.gamma-ci", "umg/up.dlt.redmine"])
  end
  after do
    @user.delete
  end
  subject { ::RoleMapper.roles(@user.login) }
  it { is_expected.to eq(["umg/up.dlt.gamma-ci", "umg/up.dlt.redmine"]) }
end
