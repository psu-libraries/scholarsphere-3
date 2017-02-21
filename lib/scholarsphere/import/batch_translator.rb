# frozen_string_literal: true
module Import
  # Imports a Sufia 6.0-exported GenericFile into a Sufia PCDM GernericWork and FileSet
  class BatchTranslator < Sufia::Import::Translator
    private

      def build_from_json(json)
        work_ids = json['generic_file_ids']
        return if work_ids.length < 2 # skip anything that doesn't have at least two works
        works = work_ids.map { |id| GenericWork.find(id) }
        works.each do |work|
          work.related_objects = works - [work]
        end
      end

      def default_prefix
        "batch_"
      end
  end
end
