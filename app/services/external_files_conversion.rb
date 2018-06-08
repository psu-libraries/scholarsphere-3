# frozen_string_literal: true

class ExternalFilesConversion
  attr_reader :work

  def initialize(work)
    @work = work
  end

  def convert
    @work.all.each do |work|
      begin
        if work.file_sets.first.original_file.nil? == false
          IngestFileJob.perform_now(work.file_sets.first, working_file(work.file_sets.first.original_file, work.file_sets.first.id), User.batch_user, filename: work.file_sets.first.original_file.original_name)
        end
      rescue OpenURI::HTTPError
        Rails.logger.warn "Problem accessing the URI for GenericWork: #{work.id}"
      rescue Ldp::HttpError
        Rails.logger.warn "Problem accessing the Fedora URI for GenericWork #{work.id}"
      end
    end
  end

  private

    def working_file(file, id)
      CurationConcerns::WorkingDirectory.copy_repository_resource_to_working_directory(file, id)
    end
end
