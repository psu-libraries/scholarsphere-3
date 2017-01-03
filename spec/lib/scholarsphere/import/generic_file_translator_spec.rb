# frozen_string_literal: true
require 'rails_helper'

describe Import::GenericFileTranslator do
  it "creates the ScholarSphere FileSet builder" do
    expect(described_class.new({}).instance_variable_get(:@file_set_builder).class).to eq(Import::FileSetBuilder)
  end
end
