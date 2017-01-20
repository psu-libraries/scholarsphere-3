# frozen_string_literal: true
module Import
  # Imports a Sufia 6.0-exported GenericFile into a Sufia PCDM GernericWork and FileSet
  class BatchTranslator < Sufia::Import::Translator
    private

      def build_from_json(json)
        work_ids = json['generic_file_ids']
        works = work_ids.map { |id| GenericWork.find(id) }
        works.each do |work|
          work.related_objects = works - [work]
          work.save
        end
      end

      def default_prefix
        "batch_"
      end
  end
end
