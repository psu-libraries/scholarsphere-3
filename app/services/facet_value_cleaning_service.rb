# frozen_string_literal: true

class FacetValueCleaningService
  class << self
    # @param [Array<String>] values
    # @param [FieldConfig] config of the field that we need to process the values
    # @return [Array<String>] the processed values
    def call(values, config, solr_document = nil)
      cleaners = config.opts.fetch(:facet_cleaners, [])
      return values unless cleaners.present? && values.is_a?(Array)

      run_cleaners(values, cleaners, solr_document)
    end

    private

      def run_cleaners(values, cleaners, solr_document)
        if cleaners.include?(:titleize)
          titleize(values)
        elsif cleaners.include?(:downcase)
          downcase(values)
        elsif cleaners.include?(:creator)
          creator(solr_document)
        else
          values
        end
      end

      def titleize(values)
        values.map { |name| name.titleize.gsub(/[\.\,]/, '') }
      end

      def downcase(values)
        values.map { |name| name.downcase.gsub(/[\.\,]/, '') }
      end

      def creator(solr_document)
        Array.wrap(solr_document['creator_facet_name_tesim'])
      end
  end
end
