# frozen_string_literal: true

class ZipFile
  attr_reader :file, :resource

  delegate :exist?, :parent, :basename, to: :file

  # @param [File, Pathname] file to be treated as a zip file
  def initialize(file)
    @file = Pathname.new(file)
    @resource = resource_from_zip(@file)
  end

  # @note This won't raise any hubbub if the file doesn't exist
  def delete
    FileUtils.rm_f(file)
  end

  def exceeds_threshold?
    return false unless resource

    resource.fetch('bytes_lts', 0) > ScholarSphere::Application.config.zipfile_size_threshold
  end

  def stale?
    return true unless resource && exist?

    DateTime.parse(resource.fetch('system_modified_dtsi')) > file.mtime
  end

  private

    def resource_from_zip(file)
      SolrDocument.find(file.basename('.*').to_s)
    rescue Blacklight::Exceptions::RecordNotFound
      nil
    end
end
