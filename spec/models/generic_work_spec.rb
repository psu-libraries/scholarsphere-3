# frozen_string_literal: true
require 'spec_helper'

describe GenericWork do
  let(:work) { create(:work) }

  subject { work }

  it "creates a noid on save" do
    expect(subject.id.length).to eq 9
  end
end
