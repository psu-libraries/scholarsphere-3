# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::Job, type: :job do
  let(:resource) { instance_double(Scholarsphere::Migration::Resource) }

  it 'migrates a resource' do
    expect(resource).to receive(:migrate)
    described_class.perform_now(resource)
  end
end
