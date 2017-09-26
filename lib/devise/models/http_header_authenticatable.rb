# frozen_string_literal: true

require 'devise/strategies/http_header_authenticatable'
module Devise
  module Models
    module HttpHeaderAuthenticatable
      extend ActiveSupport::Concern

      def after_database_authentication; end
    end
  end
end
