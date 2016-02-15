# frozen_string_literal: true
# Default strategy for signing in a user, based on his email and password in the database.
module Behaviors
  module HttpHeaderAuthenticatableBehavior
    # Called if the user doesn't already have a rails session cookie
    def valid_user?(headers)
      !remote_user(headers).blank?
    end

    protected

      def remote_user(headers)
        return headers['REMOTE_USER'] if headers['REMOTE_USER']
        return headers['HTTP_REMOTE_USER'] if headers['HTTP_REMOTE_USER'] && Rails.env.development?
        nil
      end
  end
end
