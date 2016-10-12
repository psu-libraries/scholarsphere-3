# frozen_string_literal: true
require 'spec_helper'

describe CurationConcerns::FileSetsController do
  describe "::show_presenter" do
    its(:show_presenter) { is_expected.to eq(::FileSetPresenter) }
  end
end
