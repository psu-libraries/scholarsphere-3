# frozen_string_literal: true
require 'rails_helper'

describe Sufia::BatchUploadsController do
  its(:form_class) { is_expected.to eq(::BatchUploadForm) }
end
