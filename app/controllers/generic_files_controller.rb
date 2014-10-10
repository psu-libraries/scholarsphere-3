class GenericFilesController < ApplicationController
  include Sufia::Controller
  include Sufia::FilesControllerBehavior
  include Behaviors::PermissionsNotificationBehavior

  around_action :notify_users_of_permission_changes, only: [:destroy,:create,:update]
  skip_before_action :has_access?, only: [:stats]
  skip_load_resource(only: [:show])
  before_filter :load_resource_from_solr, only: [:show]

  def load_resource_from_solr
    @generic_file = GenericFile.load_instance_from_solr(params[:id])
    @generic_file
  end

  def notify_users_of_permission_changes
    previous_permissions = @generic_file.permissions unless @generic_file.nil?
    yield
    current_permissions = @generic_file.permissions unless @generic_file.nil?
    permission_state = evaluate_permission_state(previous_permissions,current_permissions)
    notify_users(permission_state)
  end

  # Overriding Sufia::FilesControllerBehavior to save on_behalf_of
  def update_metadata_from_upload_screen
    super
    @generic_file.on_behalf_of = params[:on_behalf_of] if params[:on_behalf_of]
  end
end
