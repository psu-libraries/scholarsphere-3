# frozen_string_literal: true
FactoryGirl.define do
  factory :file_set do
    transient do
      user { FactoryGirl.create(:user) }
    end
    after(:build) do |fs, evaluator|
      fs.apply_depositor_metadata evaluator.user.user_key
    end

    trait :public do
      read_groups ["public"]
    end

    trait :registered do
      read_groups ["registered"]
    end

    trait :with_png do
      transient do
        id "fixturepng"
      end
      initialize_with { new(id: id) }
      title ["fake_image.png"]
      mime_type 'image/png'
      before(:create) do |fs|
        fs.title = ["Sample PNG"]
      end
    end

    trait :pdf do
      title ["fake_document.pdf"]
      mime_type 'image/pdf'
    end
  end
end
