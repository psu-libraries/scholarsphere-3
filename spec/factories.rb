FactoryGirl.define do
  factory :jill, class: User do |u|
    login 'jilluser'
    display_name 'Jill Z. User'
    title "User"
    ldap_available true
  end

  factory :user_with_fixtures, class: User do |u|
    login 'userwithfixtures'
    title "User"
    after(:create) do |user|
      message = '<span class="batchid ui-helper-hidden">fake_batch_id</span>You\'ve got mail.'
      User.batchuser().send_message(user, message, "Sample notification.")
    end
  end

  factory :archivist, class: User do |u|
    login 'archivist1'
    title "Archivist"
    ldap_available true
  end

  factory :curator, class: User do |u|
    login 'curator1'
    title "Curator"
    ldap_available true
    group_list 'umg/up.dlt.scholarsphere-admin-viewers'
    groups_last_update Time.now
  end

  factory :random_user, class: User do |u|
    sequence(:login) {|n| "user#{n}" }
    title "User"
    ldap_available true
  end


  #these two users are ONLY for ensuring our staging test users don't show up in search results
  factory :test_user_1, class: User do |u|
    login 'tstem31'
  end

  factory :test_user_2, class: User do |u|
    login 'testapp'
  end

end
