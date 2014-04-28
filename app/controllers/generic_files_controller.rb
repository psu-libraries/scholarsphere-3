class GenericFilesController < ApplicationController
  require_relative '../../app/controllers/concerns/permission_notification'
  include Sufia::Controller
  include Sufia::FilesControllerBehavior
  include Scholarsphere::PermissionNotification

  # Overriding Sufia::FilesControllerBehavior to save on_behalf_of
  def update_metadata_from_upload_screen
    super
    @generic_file.on_behalf_of = params[:on_behalf_of] if params[:on_behalf_of]
  end
end
