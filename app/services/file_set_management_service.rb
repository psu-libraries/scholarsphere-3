# frozen_string_literal: true
class FileSetManagementService
  attr_reader :ids
  attr_writer :errors

  def initialize(ids = nil)
    @ids = ids.present? ? ids : all_ids
  end

  def create_derivatives
    ids.map { |id| queue_derivatives_job(id) }
    logger.error("Total errors: #{errors}") if errors > 0
  end

  def characterize
    ids.map { |id| queue_characterization_job(id) }
    logger.error("Total errors: #{errors}") if errors > 0
  end

  def errors
    @errors ||= 0
  end

  private

    def logger
      @logger ||= Rails.logger
    end

    def all_ids
      args = { fq: "#{Solrizer.solr_name('has_model', :symbol)}:FileSet", fl: ["id"], rows: "100000" }
      ActiveFedora::SolrService.query("*:*", args).map(&:id)
    end

    def queue_derivatives_job(id)
      file_set = FileSet.find(id)
      CreateDerivativesJob.perform_later(file_set, file_set.original_file.id)
    rescue StandardError => e
      self.errors += 1
      logger.error "Error processing file set: #{id}\r\n#{e.message}\r\n#{e.backtrace.inspect}"
    end

    def queue_characterization_job(id)
      file_set = FileSet.find(id)
      CharacterizeJob.perform_later(file_set, file_set.original_file.id)
    rescue StandardError => e
      self.errors += 1
      logger.error "Error processing file set: #{id}\r\n#{e.message}\r\n#{e.backtrace.inspect}"
    end
end
