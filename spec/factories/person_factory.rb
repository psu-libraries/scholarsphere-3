# frozen_string_literal: true

FactoryGirl.define do
  factory :person, aliases: [:creator] do
    sequence(:first_name) { |n| "First Name #{n}" }
    sequence(:last_name) { |n| "Last Name #{n}" }
  end
end
