# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FactoryGirl.define do
  factory :user, :class => User do |u|
    login 'jilluser'
    display_name 'Jill Z. User'
    title "User"
    ldap_available true
  end

  factory :user_with_fixtures, :class => User do |u|
    login 'userwithfixtures'
    title "User"
    after(:create) do |user|
      message = '<span class="batchid ui-helper-hidden">fake_batch_noid</span>You\'ve got mail.'
      User.batchuser().send_message(user, message, "Sample notification.")
    end
  end

  factory :archivist, :class => User do |u|
    login 'archivist1'
    title "Archivist"
    ldap_available true
  end

  factory :curator, :class => User do |u|
    login 'curator1'
    title "Curator"
    ldap_available true
  end

  factory :random_user, :class => User do |u|
    sequence(:login) {|n| "user#{n}" }
    title "User"
    ldap_available true
  end

  factory :user_with_groups, :class => User do |u|
    login 'userwithgroups'
    title "User"
    display_name 'UserWithGroup'
    ldap_available true
    group_list ['umg/up.dlt.gamma-ci','umg/up.dlt.redmine'].join(";?;")
    groups_last_update Time.now
  end


  #these two users are ONLY for ensuring our staging test users don't show up in search results
  factory :test_user_1, :class => User do |u|
    login 'tstem31'
  end

  factory :test_user_2, :class => User do |u|
    login 'testapp'
  end

end

