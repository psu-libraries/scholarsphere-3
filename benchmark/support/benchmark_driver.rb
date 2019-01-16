# frozen_string_literal: true

module BenchmarkDriver
  DEFAULT_BROWSER = 'chrome'

  def driver
    @driver ||= init_driver
  end

  def browser_name
    @browser_name ||= ENV.fetch('BENCHMARK_BROWSER', DEFAULT_BROWSER)
  end

  private

    def init_driver
      web_driver = Selenium::WebDriver.for(browser_name.to_sym, http_client: client, options: options)
      web_driver.manage.timeouts.implicit_wait = implicit_wait_time
      web_driver
    end

    def client
      Selenium::WebDriver::Remote::Http::Default.new(read_timeout: 360)
    end

    def options
      if browser_name == DEFAULT_BROWSER
        Selenium::WebDriver::Chrome::Options.new(args: args)
      else
        Selenium::WebDriver::Firefox::Options.new(args: args)
      end
    end

    def args
      return [] unless headless?

      ['--headless']
    end
end
