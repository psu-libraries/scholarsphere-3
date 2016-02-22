# frozen_string_literal: true
FactoryGirl.define do
  sequence :login, 1000 do |n|
    "user#{n}"
  end

  factory :ladp_user, class: User do
    factory :ldap_jill do
      login 'jilluser'
      display_name 'Jill Z. User'
      title 'LDAP User'
    end
  end

  factory :user do
    login
    display_name 'Joe Example'
    title 'User'

    # Scholarsphere grants uploading rights to PSU users. We know
    # that a user is a PSU user if their information is in LDAP. This
    # is where we stub that information out to force it to be true.
    ldap_available true
    ldap_last_update { Time.zone.now }

    # This user should be able to log in and modify metadata, but not
    # upload files.
    factory :non_psu_user do
      ldap_available false
      ldap_last_update { Time.zone.now }
    end

    factory :administrator do
      login 'administrator1'
      display_name 'Administrator 1'
      title 'Administrator'
      group_list 'umg/up.dlt.scholarsphere-admin-viewers'
      groups_last_update Time.now
    end

    factory :first_proxy do
      display_name 'First Proxy'
    end

    factory :second_proxy do
      display_name 'Second Proxy'
    end

    factory :archivist do
      login 'archivist1'
      title 'Archivist'
    end

    factory :curator do
      login 'curator1'
      title 'Curator'
      group_list 'umg/up.dlt.scholarsphere-admin-viewers'
      groups_last_update Time.now
    end

    factory :random_user do
      display_name 'Random User'
    end

    factory :jill do
      login 'jilluser'
      display_name 'Jill Z. User'
    end
  end
end
