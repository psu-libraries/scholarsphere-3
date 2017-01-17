# frozen_string_literal: true
require 'rails_helper'

describe "Environment variable configuration" do
  it "uses application.yml to add variables and values" do
    expect(ENV["useless-variable"]).to eq("foo")
  end
end
