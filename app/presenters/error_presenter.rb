# frozen_string_literal: true
class ErrorPresenter
  attr_reader :exception, :error

  def initialize(exception = Scholarsphere::Error)
    @exception = exception
    log_missing_key if key_missing?
  end

  def status
    I18n.t("errors.#{error}.status", default: 500)
  end

  def title
    I18n.t("errors.#{error}.title", default: "Error")
  end

  def message
    I18n.t("errors.#{error}.message", default: "There was an error with your request")
  end

  def log_exception
    Rails.logger.error("Rendering #{status} page due to exception: #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
  end

  def log_missing_key
    Rails.logger.warn("Error key #{error} is not present in the i18n file. You may want to add it.")
  end

  private

    def error
      exception_class.to_s.underscore.gsub(/\//, "_")
    end

    def exception_class
      if exception.class == Class
        exception
      else
        exception.class
      end
    end

    def key_missing?
      !I18n.exists?("errors.#{error}", :en)
    end
end
