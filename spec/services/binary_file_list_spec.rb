# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

describe BinaryFileList do
  let(:user) { create(:user) }
  let(:output) { StringIO.new }
  let(:shas) do
    output.rewind
    output.read
  end

  before do
    allow(CharacterizeJob).to receive(:perform_later)
  end

  it 'lists all the binary files' do
    ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
    work_with_versions = create(:public_work_with_lots_of_versions, depositor: user.login)
    work_with_versions.reload
    expect(work_with_versions.file_sets.first.files).not_to be_blank
    described_class.list_files(output)
    expect(shas).to include("f7/94/b2/f794b23c0c6fe1083d0ca8b58261a078cd968967\n")
    expect(shas).to include("ad/13/c5/ad13c5e7cc6d8198f25e003bd2965b3544e52a32\n")
    expect(shas).to include("88/fb/4e/88fb4e88c15682c18e8b19b8a7b6eaf8770d33cf\n")
    expect(shas).to include("e5/22/18/e52218981218b69ebd83316d9aac4b83e6f147a7\n")
  end
end
