# frozen_string_literal: true
require "rails_helper"

describe Sufia::RedisEventStore do
  subject { described_class.instance }

  it { is_expected.to be_kind_of(Redis::Namespace) }
  its(:namespace) { is_expected.to eq("scholarsphere") }
end
