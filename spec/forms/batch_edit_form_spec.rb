# frozen_string_literal: true

require 'rails_helper'

describe BatchEditForm do
  describe '::build_permitted_params' do
    subject { described_class }

    its(:build_permitted_params) { is_expected.to include(:visibility) }
    its(:build_permitted_params) { is_expected.to include(creators: [
                                                            :id,
                                                            :display_name,
                                                            :given_name,
                                                            :sur_name,
                                                            :psu_id,
                                                            :email,
                                                            :orcid_id,
                                                            :_destroy
                                                          ]) }
  end
end
