# frozen_string_literal: true

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

    def sign_in_with_named_js(name, user = nil, opts = {})
      opts.merge!(disable_animations) if opts.delete(:disable_animations)
      unless Capybara.drivers.include?(name)
        Capybara.register_driver name do |app|
          window_size = opts[:window_size] || 'window-size=1024,768'
          capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: { args: ['no-sandbox', 'headless', 'disable-gpu', window_size, 'single-process'] })
          Capybara::Selenium::Driver.new(app,
                                           browser: :chrome,
                                           desired_capabilities: capabilities)
        end
      end
      Capybara.current_driver = name

      login_as user
    end

    def disable_animations
      { extensions: ["#{Rails.root}/spec/features/support/disable_animations.js"] }
    end

    def go_back
      page.evaluate_script('window.history.back()')
    end

    private

      # Poltergeist will append HTTP_ to headers variables, but since we check for
      # either when testing, it doesn't matter.
      def request_headers(user = nil)
        return {} unless user
        { 'REMOTE_USER' => user.login }
      end

      def driver_name(user = nil, driver_name = 'rack_test_authenticated_header')
        if user
          "#{driver_name}_#{user.login}"
        else
          "#{driver_name}_anonymous"
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

  config.before(:each, type: :feature) do |example|
    initialize_default_adminset
    allow(CharacterizeJob).to receive(:perform_later) unless example.metadata[:normal_characterize]
  end

  config.after(:each, type: :feature) do
    Capybara.use_default_driver
  end
end
