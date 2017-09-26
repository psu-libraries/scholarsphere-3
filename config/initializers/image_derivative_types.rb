# frozen_string_literal: true

# Override image mime types so we do not process tiff files since these are causing issues
#   currently the tiff files in the system are geo tiffs which just hang up the derivative generation
module Hydra::Works::MimeTypes::ClassMethods
  def image_mime_types
    ['image/png', 'image/jpeg', 'image/jpg', 'image/jp2', 'image/bmp', 'image/gif']
  end
end
