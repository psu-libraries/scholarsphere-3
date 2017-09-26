# frozen_string_literal: true

class FileSetPresenter < Sufia::FileSetPresenter
  include ActionView::Helpers::NumberHelper

  # See https://github.com/projecthydra/sufia/issues/1478
  # TODO: What do we want to do about related files?
  def related_files
    []
  end

  # TODO: remove this if https://github.com/projecthydra/curation_concerns/issues/1057 is resolved
  def file_size
    number_to_human_size(super)
  end

  def display_download_link?
    CurationConcerns.config.display_media_download_link
  end

  def permission_badge_class
    PublicPermissionBadge
  end
end
