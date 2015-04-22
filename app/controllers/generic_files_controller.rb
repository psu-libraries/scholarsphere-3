class GenericFilesController < ApplicationController
  include Sufia::Controller
  include Sufia::FilesControllerBehavior
  include Behaviors::PermissionsNotificationBehavior

  prepend_before_filter only: [:show, :edit] do  
    handle_legacy_url_prefix { |new_id| redirect_to sufia.generic_file_path(new_id), status: :moved_permanently }
  end 

  # TODO This is a temporary override of sufia to fix #101
  #      This can be removed once sufia has a solution and we upgrade or
  #      batches are no longer used when sufia migrates to PCDM
  # routed to /files/new
  def new
    @batch_id  = Batch.create.id
  end

  # TODO: notify_users_of_permission_changes is causing problems (#9677)
  around_action :notify_users_of_permission_changes, only: [:destroy,:create,:update]
  skip_before_action :has_access?, only: [:stats]
  
  skip_load_resource(only: [:show])
  before_filter :load_resource_from_solr, only: [:show]
  authorize_resource only: [:show]

  def load_resource_from_solr
    @generic_file = GenericFile.load_instance_from_solr(params[:id])
    @generic_file
  end

  def notify_users_of_permission_changes
    previous_permissions = @generic_file.permissions.map(&:to_hash) unless @generic_file.nil?
    yield
    unless @generic_file.nil?
      current_permissions = @generic_file.permissions.map(&:to_hash)
      permission_state = evaluate_permission_state(previous_permissions,current_permissions)
      notify_users(permission_state, @generic_file)
    end
  end

  def audit_service
    ScholarsphereAuditService.new(@generic_file)
  end

end
