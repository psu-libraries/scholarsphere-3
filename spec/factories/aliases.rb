# frozen_string_literal: true

FactoryGirl.define do
  factory :alias do
    sequence(:display_name) { |n| "Display Name #{n}" }

    trait :with_person do
      after(:build) do |resource|
        resource.person = Person.new(sur_name: 'Sur Name', given_name: 'Given Name')
      end
    end

    factory :creator do
      with_person
    end
  end
end
