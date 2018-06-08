# frozen_string_literal: true

# This module overrides CurationConcerns::WorkingDirectory to provide support for external files.

# @note these are all class methods, but we're using
#  singleton_class.send(:prepend, PrependedServices::WithExternalFileSupport)
# to prepend them to the class, and doing so means they are not defined explicitly as class methods.
module PrependedServices::WithExternalFileSupport
  def copy_file_to_working_directory(file, id)
    file_name = file.respond_to?(:original_filename) ? file.original_filename.match(/[^\/]+$/)[0] : ::File.basename(file)
    copy_stream_to_working_directory(id, file_name, file)
  end

  def copy_repository_resource_to_working_directory(file, id)
    Rails.logger.debug "Loading #{file.original_name} (#{file.id}) from the repository to the working directory"
    # TODO: this causes a load into memory, which we'd like to avoid
    copy_stream_to_working_directory(id, file.original_name, file.content)
  end

  private

    def copy_stream_to_working_directory(id, name, stream)
      working_path = full_filename(id, name)
      Rails.logger.debug "Writing #{name} to the working directory at #{working_path}"
      FileUtils.mkdir_p(File.dirname(working_path))
      stream.rewind
      IO.copy_stream(stream, working_path)
      working_path
    end
end
