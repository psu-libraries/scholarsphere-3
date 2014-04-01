
FactoryGirl.define do

  sequence :login, 1000 do |n|
    "user#{n}"
  end

  factory :user do |u|
    login
    display_name "Joe Example"
    title "User"

    # Scholarsphere grants uploading rights to PSU users. We know
    # that a user is a PSU user if their information is in LDAP. This
    # is where we stub that information out to force it to be true.
    ldap_available true
    ldap_last_update { Time.zone.now }
  end

end
