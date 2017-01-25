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

  def page_title
    "File | #{title.first} | File ID: #{solr_document.id} | ScholarSphere"
  end
end
