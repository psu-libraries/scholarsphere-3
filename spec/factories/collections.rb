# frozen_string_literal: true
FactoryGirl.define do
  factory :collection do
    transient do
      user { FactoryGirl.create(:user) }
    end
    sequence(:title) { |n| ["Title #{n}"] }
    sequence(:description) { |n| ["Description #{n}"] }
    sequence(:creator) { |n| ["Creator #{n}"] }
    after(:build) do |collection, attrs|
      collection.apply_depositor_metadata((attrs.depositor || attrs.user.user_key))
    end

    factory :public_collection do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    factory :private_collection do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end

    factory :my_collection do
      title ["My collection"]
      description "My incredibly detailed description of the collection"
      creator ["The Collector"]
    end
  end
end
