FactoryGirl.define do

  sequence :login, 1000 do |n|
    "user#{n}"
  end

  factory :user do |u|
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

    factory :administrator, class: User do |u|
      login 'administrator1'
      display_name 'Administrator 1'
      title 'Administrator'
      group_list 'umg/up.dlt.scholarsphere-admin-viewers'
      groups_last_update Time.now
    end

    end

end