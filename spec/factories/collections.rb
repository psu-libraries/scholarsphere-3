# frozen_string_literal: true
FactoryGirl.define do
  factory :collection do
    title "My collection"
    description "My incredibly detailed description of the collection"
    after(:build) do |file, attrs|
      file.apply_depositor_metadata((attrs.depositor || "user"))
    end
  end
end
