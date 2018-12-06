# frozen_string_literal: true

class DownloadsController < ApplicationController
  include CurationConcerns::DownloadBehavior
  if ENV['REPOSITORY_EXTERNAL_FILES'] == 'true'
    include ExternalDownloadBehavior
  end

  prepend_before_action only: [:show] do
    handle_legacy_url_prefix { |new_id| redirect_to main_app.download_path(new_id), status: :moved_permanently }
  end

  protected

    # Remove if/when projecthydra/curation_concerns#1118 is resolved
    def authorize_download!
      return params[:id] if current_user&.administrator?
      authorize! :read, params[asset_param_key]
    end

    def load_file
      return super if params['file'] == 'thumbnail' || asset.is_a?(FileSet)
      zip_service.call
    end

    def work_directory
      directory = File.dirname CurationConcerns::DerivativePath.derivative_path_for_reference(asset.id, 'zip')
      FileUtils.mkpath directory
      directory
    end

  private

    def zip_service
      case asset
      when GenericWork
        WorkZipService.new(asset, current_ability, work_directory)
      when Collection
        CollectionZipService.new(asset, current_ability, work_directory)
      else
        raise ZipServiceError, "#{asset.class} cannot be downloaded as a zip file"
      end
    end

    class ZipServiceError < StandardError; end
end
