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
      after(:build) do |f|
        f.add_file(File.open("#{Rails.root}/spec/fixtures/scholarsphere/scholarsphere_test4.pdf", 'rb'), path: 'content', original_name: 'sufia_test4.pdf')
      end
    end

    trait :characterized do
      after(:create, &:characterize)
    end

    trait :with_complete_metadata do
      title         ['titletitle']
      filename      ['filename.filename']
      tag           ['tagtag']
      based_near    ['based_nearbased_near']
      language      ['languagelanguage']
      creator       ['creatorcreator']
      contributor   ['contributorcontributor']
      publisher     ['publisherpublisher']
      subject       ['subjectsubject']
      resource_type ['resource_typeresource_type']
      description   ['descriptiondescription']
      format_label  ['format_labelformat_label']
    end
  end
end
