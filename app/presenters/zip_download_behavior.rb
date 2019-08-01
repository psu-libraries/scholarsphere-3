# frozen_string_literal: true

module ZipDownloadBehavior
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  def zip_download_path
    if bytes < ScholarSphere::Application.config.zipfile_size_threshold
      download_path(self)
    else
      public_zipfile_path
    end
  end

  private

    def public_zipfile_path
      return unless public_zipfile.exist?

      "/#{public_zipfile.parent.basename.join(public_zipfile.basename)}"
    end

    def public_zipfile
      @public_zipfile ||= ScholarSphere::Application.config.public_zipfile_directory.join("#{id}.zip")
    end
end
