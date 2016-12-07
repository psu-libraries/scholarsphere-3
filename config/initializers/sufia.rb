# frozen_string_literal: true
Sufia.config do |config|
  config.arkivo_api = true

  config.register_curation_concern :generic_work

  config.contact_email = "scholarsphere@servicedesk.css.psu.edu, umg-up.its.scholarsphere-support@groups.ucs.psu.edu"
  config.subject_prefix = "ScholarSphere Contact Form - "

  config.fits_path = "fits.sh"
  config.max_days_between_audits = 7
  config.enable_ffmpeg = true
  config.ffmpeg_path = Rails.application.config.ffmpeg_path

  config.ingest_queue_name = :files

  config.persistent_hostpath = "http://scholarsphere.psu.edu/files/"

  config.permission_levels = {
    "Choose Access" => "none",
    "View/Download" => "read",
    "Edit" => "edit"
  }

  config.owner_permission_levels = {
    "Edit" => "edit"
  }

  config.analytics = true

  # Specify a date you wish to start collecting Google Analytic statistics for.
  config.analytic_start_date = DateTime.new(2013, 3, 24)

  # If browse-everything has been configured, load the configs.  Otherwise, set to nil.
  begin
    if defined? BrowseEverything
      config.browse_everything = BrowseEverything.config
    else
      logger.warn "BrowseEverything is not installed"
    end
  rescue Errno::ENOENT
    config.browse_everything = nil
  end

  config.temp_file_base = "/tmp"

  config.derivatives_path = Rails.application.config.derivatives_path

  config.minter_statefile = Rails.application.config.minter_statefile
end
