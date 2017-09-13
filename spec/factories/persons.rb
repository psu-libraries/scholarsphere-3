# frozen_string_literal: true

FactoryGirl.define do
  factory :person do
    sequence(:given_name) { |n| "First Name #{n}" }
    sequence(:sur_name) { |n| "Last Name #{n}" }
  end
end
