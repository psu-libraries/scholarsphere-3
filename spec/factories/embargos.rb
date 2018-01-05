# frozen_string_literal: true

FactoryGirl.define do
  factory :embargo, aliases: [:public_embargo], class: Hydra::AccessControls::Embargo do
    visibility_during_embargo Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    visibility_after_embargo Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    embargo_release_date '2017-07-04 00:00:00'
  end
end
