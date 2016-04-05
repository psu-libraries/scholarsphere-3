# frozen_string_literal: true
class FileSetPresenter < Sufia::FileSetPresenter
  # See https://github.com/projecthydra/sufia/issues/1478
  # TODO: What do we want to do about related files?
  def related_files
    super
  end
end
