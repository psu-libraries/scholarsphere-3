# frozen_string_literal: true
require 'rails_helper'

describe Import::FileSetBuilder do
  it 'creates the ScholarSphere version builder' do
    expect(described_class.new(false).version_builder.class).to eq(Import::VersionBuilder)
  end
end
