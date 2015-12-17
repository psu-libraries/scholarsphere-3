module Behaviors
  module PermissionsNotificationBehavior
    protected

      # generates a hash of the file permission state including added, deleted, and modified permissions
      # format { added:  <hash of added permissions : name  => { name,access,type }
      #         deleted: <hash of deleted permissions : name => {name,access,type}
      #         modified: <hash of modified permissions : name => {name,access,type,previous_access}
      #         unchanged: <hash of unchanged permissions : name => {name,access,type}
      # }
      def evaluate_permission_state(previous_permissions, current_permissions)
        state = {}

        # append added permissions to the state hash
        state[:added] = current_permissions.to_a - previous_permissions.to_a

        # append removed permissions to the state hash
        state[:removed] = previous_permissions.to_a - current_permissions.to_a

        # return state
        state
      end

      # Overriding Sufia::FilesControllerBehavior to catch permission state broadcasting.
      def notify_users(permission_state, generic_file)
        return unless params[:action] == "update"
        sender = User.batchuser
        # iterate through added permissions, check that type is user,
        # locate and notify user of permissions change
        permission_state[:added].each do |permission|
          next unless permission[:type] == "person"
          recipient = User.find_by_user_key(permission[:name])
          sender.send_message(recipient,
                              t("scholarsphere.notifications.permissions.notification",
                                file: generic_file.title,
                                access: permission[:access]),
                              t("scholarsphere.notifications.permissions.subject")) unless recipient.nil?
        end
      end
  end
end
