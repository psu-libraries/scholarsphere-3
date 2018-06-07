# frozen_string_literal: true

require 'rails_helper'

describe ExternalFilesConversion do
  context 'when running a conversion' do
    let(:conversion) { described_class.new(GenericWork).convert }
    let(:user) { create(:user) }
    let(:work) { create(:public_work_with_png, depositor: user.login) }
    let(:file_set) { work.file_sets.first }
    let(:filepath) { File.join(fixture_path, 'world.png') }

    before do
      allow(CharacterizeJob).to receive(:perform_later)
    end

    it 'converts works that use internal files to external files' do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
      file_set
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response.to_s).to match(/OK/)
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      conversion
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response['content-disposition']).to match(/world.png/)
      expect(file_set.original_file.original_name).to eq('world.png')
      expect(response.to_s).to match(/HTTPTemporaryRedirect/)
    end
  end
end
