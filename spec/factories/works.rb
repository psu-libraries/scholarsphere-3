# frozen_string_literal: true
FactoryGirl.define do
  factory :work, aliases: [:private_file, :file, :private_work], class: GenericWork do
    transient do
      user { FactoryGirl.create(:user) }
      transfer_to nil
      file_title nil
      file_name nil
    end

    title ["Sample Title"]
    after(:build) do |file, attrs|
      file.apply_depositor_metadata((attrs.depositor || "user"))
    end

    after(:create) do |file, attrs|
      file.request_transfer_to(attrs.transfer_to) if attrs.transfer_to
    end

    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE

    factory :public_work, aliases: [:public_file] do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      factory :share_file do
        title ["SHARE Document"]
        creator ["Joe Contributor"]
        resource_type ["Dissertation"]
      end

      factory :featured_file do
        after(:create) do |f|
          FeaturedWork.create!(generic_work_id: f.id)
        end
      end

      factory :trophy_file do
        after(:create) do |f, attrs|
          Trophy.create!(user_id: User.find_by_login(attrs.depositor).id, generic_work_id: f.id)
        end
      end
    end

    factory :registered_file do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    end

    trait :with_one_file do
      before(:create) do |work, evaluator|
        work.ordered_members << FactoryGirl.create(:file_set,
                                                   user: evaluator.user,
                                                   title: (evaluator.file_title || ["A Contained File"]),
                                                   label: evaluator.file_name || 'filename.pdf')
      end
    end

    trait :with_full_text_content do
      after(:build) do |f|
        f.full_text.content = "full_textfull_text"
      end
    end

    trait :with_png do
      after(:build) do |f|
        f.add_file(File.open("#{Rails.root}/spec/fixtures/world.png", 'rb'), path: 'content')
      end
    end

    trait :with_pdf do
      before(:create) do |work, evaluator|
        work.ordered_members << FactoryGirl.create(:file_set, :pdf, user: evaluator.user)
      end
    end

    trait :characterized do
      after(:create, &:characterize)
    end

    trait :with_complete_metadata do
      title         ['titletitle']
      tag           ['tagtag']
      based_near    ['based_nearbased_near']
      language      ['languagelanguage']
      creator       ['creatorcreator']
      contributor   ['contributorcontributor']
      publisher     ['publisherpublisher']
      subject       ['subjectsubject']
      resource_type ['resource_typeresource_type']
      description   ['descriptiondescription']
      related_url   ['http://example.org/TheRelatedURLLink/']
    end
  end
end
