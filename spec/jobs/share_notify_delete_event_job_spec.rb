# frozen_string_literal: true
require 'spec_helper'

describe ShareNotifyDeleteEventJob do
  let(:user) { FactoryGirl.find_or_create(:jill) }

  let(:file) do
    GenericFile.new.tap do |f|
      f.apply_depositor_metadata(user)
      f.title = ["Shared file"]
      f.save
    end
  end

  before do
    allow_any_instance_of(described_class).to receive(:depositor).and_return(user)
    described_class.new(file.id, user.id).run
  end

  it "sends an event to the file activity stream" do
    expect(file.events.length).to eq(1)
  end
end
