# frozen_string_literal: true
# Require this file at the top of each feature spec.
require 'rails_helper'
require 'features/support/feature_cleanup'
require 'features/support/feature_sessions'
require 'features/support/batch_edit_actions'

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :feature
  config.after(:each) { Warden.test_reset! }
  config.before(:each) { allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(false) }
end
