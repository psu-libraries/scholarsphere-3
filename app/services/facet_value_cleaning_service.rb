# frozen_string_literal: true
class FacetValueCleaningService
  # @param [Array<String>] values
  # @param [FieldConfig] config of the field that we need to process the values
  # @return [Array<String>] the processed values
  def self.call(values, config)
    cleaners = config.opts.fetch(:facet_cleaners, [])
    return values unless cleaners.present? && values.is_a?(Array)

    if cleaners.include?(:titleize)
      values.map { |name| name.titleize.gsub(/[\.\,]/, '') }
    elsif cleaners.include?(:downcase)
      values.map { |name| name.downcase.gsub(/[\.\,]/, '') }
    else
      values
    end
  end
end
