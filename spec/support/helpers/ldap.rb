# frozen_string_literal: true

# This method mimics ldap if we are on travis
# otherwise it allows the connection to ldap to make this more of an integration test
def expect_ldap(method, response, *args)
  return unless travis?
  expect(LdapDisambiguate::LdapUser).to receive(method).with(*args).and_return(response)
end

def format_name_response(id, first_name, last_name, affiliation = 'STAFF')
  [{ id: id,
     given_name: first_name,
     surname: last_name,
     email: "#{id}@psu.edu",
     affiliation: [affiliation],
     displayname: ["#{first_name} #{last_name}"] }]
end
