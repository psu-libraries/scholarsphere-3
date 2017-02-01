# frozen_string_literal: true
RSpec.configure do |config|
  config.before do
    allow(ScholarSphere::Application.config).to receive(:read_only).and_return(false)
  end
end
