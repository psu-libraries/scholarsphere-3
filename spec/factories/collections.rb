# frozen_string_literal: true
FactoryGirl.define do
  factory :collection do
    title "My collection"
    description "My incredibly detailed description of the collection"
    creator ["The Collector"]
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    after(:build) do |file, attrs|
      file.apply_depositor_metadata((attrs.depositor || "user"))
    end
  end
end
