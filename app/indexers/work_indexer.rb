# frozen_string_literal: true

class WorkIndexer < Sufia::WorkIndexer
  include IndexesCreator

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('file_set_ids', :symbol)] = solr_doc[Solrizer.solr_name('member_ids', :symbol)]
      solr_doc[Solrizer.solr_name('resource_type', :facetable)] = object.resource_type
      solr_doc[Solrizer.solr_name('file_format', :stored_searchable)] = file_format
      solr_doc[Solrizer.solr_name('file_format', :facetable)] = file_format
      solr_doc['readme_file_ss'] = readme_file.content
      solr_doc[Solrizer.solr_name(:bytes, CurationConcerns::CollectionIndexer::STORED_LONG)] = object.bytes
      SolrDocumentGroomer.call(solr_doc)
    end
  end

  private

    def representative
      object.representative || NullRepresentative.new
    end

    def readme_file
      @readme_file ||= ReadmeFile.new(object.readme_file)
    end

    # Use the naught gem if this gets bigger
    class NullRepresentative
      def file_format
        nil
      end
    end

    class ReadmeFile
      attr_reader :file

      def initialize(file)
        @file = file
      end

      def content?
        !file.nil? && file.original_file.respond_to?(:content)
      end

      def content
        return unless content?

        @content ||= retrieve_and_encode
      end

      def retrieve_and_encode
        retrieved_content = case file.original_file.content
                            when String
                              file.original_file.content
                            when StringIO, File
                              file.original_file.content.read
                            end
        EncodingService.call(retrieved_content)
      end
    end

    def file_format
      @file_format ||= representative.file_format
    end
end
