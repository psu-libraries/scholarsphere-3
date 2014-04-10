module Behaviors
  module PermissionsNotificationBehavior

    protected

    #generates a hash of the file permission state including added, deleted, and modified permissions
    #format { added:  <hash of added permissions : name  => { name,access,type }
    #         deleted: <hash of deleted permissions : name => {name,access,type}
    #         modified: <hash of modified permissions : name => {name,access,type,previous_access}
    #         unchanged: <hash of unchanged permissions : name => {name,access,type}
    # }
    def evaluate_permission_state(previous_permissions,current_permissions)
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

      #return state
      return state
    end

    # Overriding Sufia::FilesControllerBehavior to catch permission state broadcasting.
    def notify_users(permission_state)
      #retrieve batch user
      sender = User.batchuser

      #check if file state is modified representing permissions could be updated
      if params[:action]=="update"

        #iterate through added permissions, check that type is user,
        #locate and notify user of permissions change
        permission_state[:added].each do |userid,entry|
          if entry[:type]=="user"
            recipient = User.find_by_user_key(userid)
            sender.send_message(recipient,
                                t("scholarsphere.notifications.permissions.notification",
                                  file: @generic_file.title,
                                  access: entry[:access]),
                                t("scholarsphere.notifications.permissions.subject")) unless recipient.nil?

          end
        end
      end
    end
  end
end
