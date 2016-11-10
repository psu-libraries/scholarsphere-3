# frozen_string_literal: true
class FileContentDatastream < ActiveFedora::File
  include Hydra::Derivatives::ExtractMetadata
  include Sufia::FileContent::Versions

  def extract_metadata
    return unless has_content?
    stream_service = GenericFileContentService.new(GenericFile.find(id.gsub('/content', '')))
    Hydra::FileCharacterization.characterize(stream_service.stream_content, stream_service.stream_content.path, :fits) do |config|
      config[:fits] = Hydra::Derivatives.fits_path
    end
  ensure
    stream_service.cleanup
  end
end
