# frozen_string_literal: true
module AdditionalMetadata
  include ActiveSupport::Concerns

  def url
    "#{current_host}#{path}"
  end

  def time_uploaded
    return '' if date_uploaded.blank?
    date_uploaded.strftime('%Y-%m-%d %H:%M:%S')
  end

  private

    def current_host
      Rails.application.config.virtual_host.chomp('/')
    end

    def path
      Rails.application.routes.url_helpers.send("curation_concerns_#{self.class.to_s.underscore}_path", self)
    end
end
