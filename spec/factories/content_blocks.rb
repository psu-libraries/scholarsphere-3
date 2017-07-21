# frozen_string_literal: true
FactoryGirl.define do
  factory :content_block do
    factory :marketing_text do
      name "marketing_text"
      value "Share. Manage. Preserve."
    end

    factory :license_text do
      name "license_text"
      value "License here, license there, license everywhere"
    end
  end
end
