module Scholarsphere
  module PermissionNotification
    extend ActiveSupport::Concern

    included do
      after_initialize :store_current_permissions
      after_update :evaluate_permission_deltas
    end #end included

    # stores the current permissions of the generic file in a variable
    def store_current_permissions
      @previous_permissions ||= permissions
    end #end store_previous_permissions

    # evaluates permission deltas and notifies users of access
    def evaluate_permission_deltas
      previous_permissions = @previous_permissions
      current_permissions = permissions
      permission_state = calculate_permission_state(previous_permissions,current_permissions)
      notify_users_of_access(permission_state)
    end #end evaluate_permission_deltas

    #generates a hash of the file permission state including added, deleted, and modified permissions
    #format { added:  <hash of added permissions : name  => { name,access,type }
    #         deleted: <hash of deleted permissions : name => {name,access,type}
    #         modified: <hash of modified permissions : name => {name,access,type,previous_access}
    #         unchanged: <hash of unchanged permissions : name => {name,access,type}
    # }
    def calculate_permission_state(previous_permissions,current_permissions)
      state = {}
      chash = {}
      phash = {}

      #converts current permissions to key value hash where user id is hash
      chash = current_permissions.inject({}){|result,el| result[el[:name]]=el; result} unless current_permissions.nil?

      #converts previous permissions to key value hash where user id is hash
      phash = previous_permissions.inject({}){|result,el| result[el[:name]]=el; result} unless previous_permissions.nil?

      #append added permissions to the state hash
      state[:added] = {}
      (chash.keys - phash.keys).each{ |key| state[:added][key] = chash[key].deep_dup }

      #append removed permissions to the state hash
      state[:removed] = {}
      (phash.keys - chash.keys).each{ |key| state[:removed][key] = phash[key].deep_dup }

      #append modified or unchanged permissions to the state hash
      state[:modified] = {}
      state[:unchanged] = {}
      (phash.keys & chash.keys).each do |key|
        if phash[key].eql?(chash[key])
          state[:unchanged][key] = phash[key].deep_dup
        else
          state[:modified][key] = phash[key].deep_dup
          state[:modified][key][:previous_access] = chash[key][:access]
        end
      end

      return state
    end #end calculate_permission_state

    # retrieve user/user(s) who should be notified and send notification
    def notify_users_of_access(permission_state)
      depositor = self.depositor
      permission_state[:added].each do |entityid,entry|
        if entry[:type]=="user"
          user = User.find_by_user_key(entityid)
          send_notification(user,entry[:access]) unless user.nil? || user.login == depositor
        else
          User.users_of_group(entityid).each do |user|
            send_notification(user,entry[:access]) unless user.login == depositor
          end
        end
      end
    end #end notify_users_of_access

    # send user notification
    def send_notification(recipient,access)
      depositor = self.depositor
      sender = User.batchuser
      sender.send_message(recipient,
                          I18n.t('scholarsphere.notifications.permissions.notification',
                                 user: depositor,
                                 file: title[0],
                                 access: access == 'read'? 'View/Download' : 'Edit'),
                          I18n.t('scholarsphere.notifications.permissions.subject')) unless recipient.nil?
    end #end send_notification

  end #end PermissionNotification
end #end Scholarsphere