# frozen_string_literal: true

FactoryGirl.define do
  factory :agent do
    sequence(:given_name) { |n| "First Name #{n}" }
    sequence(:sur_name) { |n| "Last Name #{n}" }
  end

  trait :with_complete_metadata do
    given_name { 'Johnny C.' }
    sur_name   { 'Lately' }
    email      { 'newkid@example.com' }
    psu_id     { 'jcl81' }
    orcid_id   { '00123445' }
  end

  trait :from_psu do
    given = Faker::Name.first_name
    family = Faker::Name.last_name
    access_id = [
      given.first,
      ('a'..'z').to_a.sample.first,
      family.first,
      Faker::Number.number(2)
    ].join('').downcase

    given_name { given }
    sur_name { family }
    email { "#{access_id}@psu.edu" }
    psu_id { access_id }
  end

  trait :with_orcid_id do
    orcid_id do
      Faker::Number.leading_zero_number(12).gsub(/(\d{4})[.-]?(\d{4})[.-]?(\d{4})/, '\1-\2-\3')
    end
  end
end
