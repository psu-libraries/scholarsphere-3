# frozen_string_literal: true
FactoryGirl.define do
  factory :file_set do
    transient do
      user { FactoryGirl.create(:user) }
      content nil
    end
    after(:build) do |fs, evaluator|
      fs.apply_depositor_metadata evaluator.user.user_key
    end

    after(:create) do |file, evaluator|
      if evaluator.content
        Hydra::Works::UploadFileToFileSet.call(file, evaluator.content)
      end
    end

    trait :public do
      read_groups ['public']
    end

    trait :registered do
      read_groups ['registered']
    end

    trait :with_png do
      transient do
        id 'fixturepng'
      end
      initialize_with { new(id: id) }
      title ['fake_image.png']
      before(:create) do |fs|
        fs.title = ['Sample PNG']
      end
    end

    trait :pdf do
      title ['fake_document.pdf']
      before(:create) do |fs|
        fs.title = ['Fake PDF Title']
      end
    end

    trait :with_file_size do
      after(:build) do |fs|
        allow(fs).to receive(:file_size).and_return('1234')
      end
    end
  end
end
