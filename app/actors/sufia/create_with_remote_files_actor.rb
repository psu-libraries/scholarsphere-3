# frozen_string_literal: true

# Overrides Sufia. Adds in visibility attributes that Sufia does not handel
module Sufia
  # Attaches remote files to the work
  class CreateWithRemoteFilesActor < CurationConcerns::Actors::AbstractActor
    attr_reader :visibility_attributes

    def create(attributes)
      register_visibility_attributes(attributes)
      remote_files = attributes.delete(:remote_files)
      next_actor.create(attributes) && attach_files(remote_files)
    end

    def update(attributes)
      register_visibility_attributes(attributes)
      remote_files = attributes.delete(:remote_files)
      next_actor.update(attributes) && attach_files(remote_files)
    end

    protected

      # @param [HashWithIndifferentAccess]
      # @return [TrueClass]
      def attach_files(remote_files)
        return true unless remote_files
        remote_files.each do |file_info|
          next if file_info.blank? || file_info[:url].blank?
          create_file_from_url(file_info[:url], file_info[:file_name])
        end
        true
      end

      # Generic utility for creating FileSet from a URL
      # Used in to import files using URLs from a file picker like browse_everything
      def create_file_from_url(url, file_name)
        ::FileSet.new(import_url: url, label: file_name) do |fs|
          actor = CurationConcerns::Actors::FileSetActor.new(fs, user)
          actor.create_metadata(curation_concern, visibility_attributes)
          fs.save!
          uri = URI.parse(URI.encode(url))
          if uri.scheme == 'file'
            IngestLocalFileJob.perform_later(fs, URI.decode(uri.path), user)
          else
            ImportUrlJob.perform_later(fs, file_name, log(actor.user))
          end
        end
      end

      def log(user)
        CurationConcerns::Operation.create!(user: user,
                                            operation_type: 'Attach Remote File')
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
end
