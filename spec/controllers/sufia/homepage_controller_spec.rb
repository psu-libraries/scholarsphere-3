# frozen_string_literal: true

require 'rails_helper'

describe Sufia::HomepageController do
  subject { described_class.new }

  its(:sort_field) { is_expected.to eq('date_uploaded_dtsi desc') }
end
