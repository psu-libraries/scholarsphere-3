# frozen_string_literal: true

module Migration
  class SolrObjectList
    attr_reader :objects, :object_class

    def initialize(object_class)
      @object_class = object_class
      @objects = ActiveFedora::SolrService.query(filter, fl: 'id,depositor_tesim', rows: 100000).map(&:id)
    end

    def each_with_load
      objects.each do |id|
        begin
          yield(load_object(id))
        rescue ActiveFedora::ObjectNotFoundError => error
          Rails.logger.warn "error finding object to migrate: #{id}; #{error}"
        rescue StandardError => error
          Rails.logger.warn "error migrating object: #{id}; #{error}"
        end
      end
    end

    private

      def filter
        "has_model_ssim:#{object_class}"
      end

      def load_object(id)
        object_class.find(id)
      end
  end
end
