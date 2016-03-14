# frozen_string_literal: true
require 'active_fedora/cleaner'
# The other tests rely on a clean database *before* each test. So we
# clean up after ourselves here.
RSpec.configure do |config|
  config.before(:each) do
    allow(Hydra::LDAP).to receive(:groups_for_user).and_return([])
    allow(Hydra::LDAP.connection).to receive(:get_operation_result).and_return(OpenStruct.new(code: 0, message: "Success"))
  end
end
