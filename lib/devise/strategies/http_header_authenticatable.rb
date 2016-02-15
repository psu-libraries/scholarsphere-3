# frozen_string_literal: true
# Default strategy for signing in a user, based on his email and password in the database.
module Devise
  module Strategies
    class HttpHeaderAuthenticatable < ::Devise::Strategies::Base
      include Behaviors::HttpHeaderAuthenticatableBehavior

      # Called if the user doesn't already have a rails session cookie
      def valid?
        valid_user?(request.headers)
      end

      def authenticate!
        user = remote_user(request.headers)
        if user.present?
          u = User.find_by_login(user)
          if u.nil?
            u = User.create(login: user, email: user)
            u.populate_attributes
          end
          success!(u)
        else
          fail!
        end
      end
    end
  end
end

Warden::Strategies.add(:http_header_authenticatable, Devise::Strategies::HttpHeaderAuthenticatable)
