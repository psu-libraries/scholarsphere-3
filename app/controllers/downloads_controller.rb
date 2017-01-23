# frozen_string_literal: true
class DownloadsController < ApplicationController
  include CurationConcerns::DownloadBehavior
  prepend_before_action only: [:show] do
    handle_legacy_url_prefix { |new_id| redirect_to sufia.download_path(new_id), status: :moved_permanently }
  end

  protected

    # Remove if/when projecthydra/curation_concerns#1118 is resolved
    def authorize_download!
      return params[:id] if current_user && current_user.administrator?
      super
    end
end
