# frozen_string_literal: true
require 'rails_helper'

describe BatchUploadForm do
  subject { described_class }

  its(:required_fields) { is_expected.to contain_exactly(:title,
                                                         :creator,
                                                         :keyword,
                                                         :rights,
                                                         :description) }
end
