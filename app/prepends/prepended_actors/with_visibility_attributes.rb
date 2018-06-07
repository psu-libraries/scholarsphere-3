# frozen_string_literal: true

module PrependedActors::WithVisibilityAttributes
  attr_reader :visibility_attributes

  def create(attributes)
    register_visibility_attributes(attributes)
    self.uploaded_file_ids = attributes.delete(:uploaded_files)
    validate_files && next_actor.create(attributes) && attach_files
  end

  def update(attributes)
    register_visibility_attributes(attributes)
    self.uploaded_file_ids = attributes.delete(:uploaded_files)
    validate_files && next_actor.update(attributes) && attach_files
  end

  protected

    # @return [TrueClass]
    def attach_files
      return true unless uploaded_files
      AttachFilesToWorkJob.perform_later(curation_concern, uploaded_files, visibility_attributes)
      true
    end

  private

    # The attributes used for visibility - used to send as initial params to
    # created FileSets.
    def register_visibility_attributes(attributes)
      @visibility_attributes = attributes.slice(:visibility, :visibility_during_lease,
                                                  :visibility_after_lease, :lease_expiration_date,
                                                  :embargo_release_date, :visibility_during_embargo,
                                                  :visibility_after_embargo)
    end
end
