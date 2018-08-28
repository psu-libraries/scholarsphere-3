# frozen_string_literal: true

module BenchmarkDriver
  def chrome_driver
    @chrome_driver ||= driver(:chrome)
  end

  def firefox_driver
    @firefox_driver ||= driver(:firefox)
  end

  private

    def driver(type)
      driver = Selenium::WebDriver.for type, options: options(type)
      driver.manage.timeouts.implicit_wait = implicit_wait_time
      driver.manage.window.maximize
      driver
    end

    def options(type)
      if type == :chrome
        Selenium::WebDriver::Chrome::Options.new(args: args)
      else
        Selenium::WebDriver::Firefox::Options.new(args: args)
      end
    end

    def args
      return [] unless headless
      ['--headless']
    end
end
