# frozen_string_literal: true
# Default strategy for signing in a user, based on his email and password in the database.
module Devise
  module Behaviors
    module HttpHeaderAuthenticatableBehavior
      # Called if the user doesn't already have a rails session cookie
      def valid_user?(headers)
        !remote_user(headers).blank?
      end

      protected

        # In production, only check for REMOTE_USER. HTTP_ is removed from the variable before
        # it is passed to the application. In test or development, this may or may not
        # happen depending on the setup or testing framework, so we allow both.
        def remote_user(headers)
          if Rails.env.production?
            headers.fetch("REMOTE_USER", nil)
          else
            headers.fetch("REMOTE_USER", nil) || headers.fetch("HTTP_REMOTE_USER", nil)
          end
        end
    end
  end
end
