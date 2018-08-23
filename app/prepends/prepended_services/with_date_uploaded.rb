# frozen_string_literal: true

# Replaces the system create date with the uploaded data in Sufia::QueryService
# so that reports are generated based on the date a work was originally deposited
# in the Scholarsphere. This takes into account any subsequent migrations that
# were done to works and files after they were deposited.

module PrependedServices::WithDateUploaded
  def build_date_query(*args)
    super(*args).gsub('system_create_dtsi', 'date_uploaded_dtsi')
  end
end
