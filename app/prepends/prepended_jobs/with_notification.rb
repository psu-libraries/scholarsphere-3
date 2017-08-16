# frozen_string_literal: true

# This is a prepend intended to be used with AttachFilesToWorkJob.
# Adds notifications to the user when files are successfully added to works, or not.
module PrependedJobs::WithNotification
  private

    # @param [CurationConcerns::Actors::FileSetActor] actor
    # @param [UploadedFileUploader] file
    def attach_content(actor, file)
      case file.file
      when CarrierWave::SanitizedFile
        add_file(actor, file.file.to_file)
      when CarrierWave::Storage::Fog::File
        import_url(actor, file)
      else
        raise ArgumentError, "Unknown type of file #{file.class}"
      end
    end

    # @param [CurationConcerns::Actors::FileSetActor] actor
    # @param [File] file
    def add_file(actor, file)
      if actor.create_content(file)
        AttachFilesToWorkSuccessService.new(actor.user, file).call
      else
        AttachFilesToWorkFailureService.new(actor.user, file).call
      end
    end
end
