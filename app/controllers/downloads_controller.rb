# frozen_string_literal: true
class DownloadsController < ApplicationController

  prepend_before_action only: [:show] do
    handle_legacy_url_prefix { |new_id| redirect_to sufia.download_path(new_id), status: :moved_permanently }
  end
end
