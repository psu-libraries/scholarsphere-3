# frozen_string_literal: true

FactoryGirl.define do
  factory :agent do
    sequence(:given_name) { |n| "First Name #{n}" }
    sequence(:sur_name) { |n| "Last Name #{n}" }
  end

  trait :with_complete_metadata do
    given_name 'Johnny C.'
    sur_name   'Lately'
    email      'newkid@example.com'
    psu_id     'jcl81'
    orcid_id   '00123445'
  end
end
