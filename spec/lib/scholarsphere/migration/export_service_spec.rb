# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::ExportService, unless: travis? do
  let(:user) { create(:user) }
  let(:creator) { create(:creator) }
  let(:work) { create(:public_work_with_pdf, :with_complete_metadata, depositor: user.login) }

  it 'exports a work to the Scholarsphere 4 ingest endpoint' do
    result = described_class.call(work.id)
    expect(result.status).to eq(200)
  end
end
