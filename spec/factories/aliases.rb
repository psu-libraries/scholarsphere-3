# frozen_string_literal: true

FactoryGirl.define do
  factory :alias do
    sequence(:display_name) { |n| "Display Name #{n}" }

    trait :with_agent do
      after(:build) do |resource|
        resource.agent = Agent.new(sur_name: 'Sur Name', given_name: 'Given Name')
      end
    end

    factory :creator do
      with_agent
    end
  end
end
