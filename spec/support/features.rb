# frozen_string_literal: true
require "#{Rails.root}/spec/support/session_helpers"

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
end
