# frozen_string_literal: true
require 'active_fedora/noid/rspec'

RSpec.configure do |config|
  include ActiveFedora::Noid::RSpec

  config.before(:suite) { disable_production_minter! }
  config.after(:suite)  { enable_production_minter! }
end
