# frozen_string_literal: true

module WithCleanerAttributes
  extend ActiveSupport::Concern

  class_methods do
    def model_attributes(form_params)
      cleaner_params = super
      terms.each do |key|
        if cleaner_params[key].is_a?(Array)
          cleaner_params[key].map!(&:squish)
        elsif cleaner_params[key].is_a?(String)
          cleaner_params[key] = cleaner_params[key].squish
        end
      end
      cleaner_params
    end
  end
end
