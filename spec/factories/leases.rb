# frozen_string_literal: true

FactoryGirl.define do
  factory :lease, aliases: [:public_lease], class: Hydra::AccessControls::Lease do
    visibility_during_lease Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    visibility_after_lease Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    lease_expiration_date '2017-07-04 00:00:00'
  end
end
