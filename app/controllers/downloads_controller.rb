class DownloadsController < ApplicationController
  include Sufia::DownloadsControllerBehavior

  prepend_before_filter only: [:show] do  
    handle_legacy_url_prefix { |new_id| redirect_to sufia.download_path(new_id), status: :moved_permanently }
  end 

end