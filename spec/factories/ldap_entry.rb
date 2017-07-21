# frozen_string_literal: true
FactoryGirl.define do
  factory :ldap_entry, class: Net::LDAP::Entry do
    transient do
      cn nil
      displayname nil
      uid nil
      givenname nil
      sn nil
      mail nil
      psofficelocation nil
    end

    initialize_with { new("uid=#{uid},dc=psu,edu") }
    after(:build) do |u, attrs|
      u["cn"] = attrs.cn
      u["displayname"] = attrs.displayname
      u["uid"] = attrs.uid
      u["givenname"] = attrs.givenname
      u["sn"] = attrs.sn
      u["mail"] = attrs.mail
      u["psofficelocation"] = attrs.psofficelocation
    end
  end
end
