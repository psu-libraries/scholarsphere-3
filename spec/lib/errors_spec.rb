# frozen_string_literal: true

require 'rails_helper'

describe Scholarsphere do
  describe Scholarsphere::Error do
    it { is_expected.to be_kind_of(StandardError) }
  end
end
