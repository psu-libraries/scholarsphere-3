# Stub out authentication for tests.

# This authentication strategy will automatically succeed for the user that was
# assigned to the `user` class variable.
class StubbedAuthenticationStrategy < ::Devise::Strategies::Base

  # Use this method to set the user that should be authenticated.
  def self.user=(user)
    @@user = user
  end

  # We're a fake authentication strategy; we always succeed.
  def authenticate!
    #TODO: ldap_last_update can't be nil for authentication
    # This happens somewhere in Hydra.
    # Since our user may have ldap_last_update as nil if created with
    # the existing factories, we'll update it here.
    # We should ideally have a separate set of factories to
    # ensure the user has the proper attributes set for authentication.
    @@user.ldap_last_update = Time.now
    @@user.save
    success!(@@user)
  end

  # Called if the user doesn't already have a rails session cookie
  def valid?
    true
  end

end

module StubbedAuthenticationHelper

  # Call this method in your "before" block to be signed in as the given user
  # (pass in the entire user object, not just a username).
  def sign_in_as(user)
    StubbedAuthenticationStrategy.user = user
  end

end

RSpec.configure do |config|

  # Stub authentication by default. If you do *not* want this to happen, then add
  # `stub_authentication: false` to your examples/blocks.

  config.before(:each) do
    unless example.metadata[:stub_authentication] == false
      Warden::Strategies.add(:http_header_authenticatable, StubbedAuthenticationStrategy)
    end
  end

  config.after(:each) do
    unless example.metadata[:stub_authentication] == false
      Warden::Strategies.add(:http_header_authenticatable, Devise::Strategies::HttpHeaderAuthenticatable)
    end
  end

  config.include(StubbedAuthenticationHelper)
end
