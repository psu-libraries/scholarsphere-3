# frozen_string_literal: true

FactoryGirl.define do
  factory :person, aliases: [:creator] do
    sequence(:given_name) { |n| "First Name #{n}" }
    sequence(:sur_name) { |n| "Last Name #{n}" }

    trait :with_metadata do
      given_name 'John Q.'
      sur_name 'Metadata'
      psu_id 'jqm123'
      orcid_id '123456789'
    end
  end
end
