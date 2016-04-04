# frozen_string_literal: true
require 'capybara/poltergeist'

module Features
  module SessionHelpers
    def sign_in(user = nil)
      driver = driver_name(user)
      Capybara.register_driver(driver) do |app|
        Capybara::RackTest::Driver.new(app,
                                       respect_data_method: true,
                                       headers: request_headers(user))
      end
      Capybara.current_driver = driver
    end

    def sign_in_with_js(user = nil, opts = {})
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, defaults.merge(opts))
      end
      Capybara.current_driver = :poltergeist
      page.driver.headers = request_headers(user)
    end

    private

      # Poltergeist will append HTTP_ to headers variables, but since we check for
      # either when testing, it doesn't matter.
      def request_headers(user = nil)
        return {} unless user
        { 'REMOTE_USER' => user.login }
      end

      def driver_name(user = nil)
        if user
          "rack_test_authenticated_header_#{user.login}"
        else
          "rack_test_authenticated_header_anonymous"
        end
      end

      def defaults
        {
          js_errors: true,
          timeout: 90,
          phantomjs_options: ['--ssl-protocol=ANY']
        }
      end
  end
end

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
end
