# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::FileSet do
  subject { described_class.new(work.file_sets.first) }

  let(:user) { create(:user) }
  let(:work) { create(:public_work_with_pdf, :with_complete_metadata, depositor: user.login) }

  before { allow_any_instance_of(CreateDerivativesJob).to receive(:perform) }

  context 'when the files exist' do
    its(:metadata) do
      is_expected.to include(
        file: an_instance_of(Pathname),
        deposited_at: work.file_sets.first.create_date,
        noid: work.file_sets.first.id
      )
    end
  end

  context 'when the files do not exist' do
    let(:mock_location) { instance_double('FileSetDiskLocation', path: 'this/is/bogus') }

    before { allow(FileSetDiskLocation).to receive(:new).and_return(mock_location) }

    its(:metadata) { is_expected.to be_nil }
  end

  context 'when there is an unspecified error accessing the file' do
    before { allow(FileSetDiskLocation).to receive(:new).and_raise(StandardError) }

    its(:metadata) { is_expected.to be_nil }
  end
end
