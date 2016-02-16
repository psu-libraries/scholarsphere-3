# frozen_string_literal: true
# Require this file at the top of each feature spec.
require 'spec_helper'
require 'features/support/feature_cleanup'
require 'features/support/feature_sessions'

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :feature
  config.after(:each) { Warden.test_reset! }
end
