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
        IngestFileJob.perform_now(file, evaluator.content.path, evaluator.user)
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

    trait :with_file_size do
      after(:build) do |fs|
        allow(fs).to receive(:file_size).and_return('1234')
      end
    end

    trait :with_file_format do
      after(:build) do |fs|
        allow(fs).to receive(:file_format).and_return('plain ()')
      end
    end

    trait :with_original_file do
      after(:create) do |fs, attributes|
        file_path = "#{Rails.root}/spec/fixtures/world.png"
        IngestFileJob.perform_now(fs, file_path, attributes.user)
      end
    end

    trait :with_virus_file do
      after(:build) do |fs, attributes|
        file_path = "#{Rails.root}/spec/fixtures/eicar.com"
        IngestFileJob.perform_now(fs, file_path, attributes.user)
      end
    end
  end
end
