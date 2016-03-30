# frozen_string_literal: true
FactoryGirl.define do
  factory :file, aliases: [:private_file], class: GenericFile do
    title ["Sample Title"]
    after(:build) do |file, attrs|
      file.apply_depositor_metadata((attrs.depositor || "user"))
    end
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE

    factory :public_file do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      factory :share_file do
        title ["SHARE Document"]
        creator ["Joe Contributor"]
        resource_type ["Dissertation"]
      end
    end

    factory :registered_file do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    end
  end
end
