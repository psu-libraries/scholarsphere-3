# frozen_string_literal: true
# TODO: When upgrading to Sufia 7, this should extend Sufia::MessageUserService
class PermissionsChangeService
  attr_reader :state, :generic_file

  # @param [PermissionsChangeSet] permission_state hash representing changes in permissions
  # @param [GenericFile] generic_file whose permissions have been changed
  def initialize(permission_state, generic_file)
    @state = permission_state
    @generic_file = generic_file
  end

  def call
    return if state.unchanged?
    inform_users
    update_share_notify
  end

  def inform_users
    state.added.each do |permission|
      next unless permission[:type] == "person"
      send_message(permission[:access], User.find_by_user_key(permission[:name]))
    end
  end

  def update_share_notify
    return if unshareable?
    send_to_share if state.publicized?
    delete_from_share if state.privatized?
  end

  private

    def unshareable?
      ResourceFilteredList.new([generic_file]).filter.empty?
    end

    def send_to_share
      Sufia.queue.push(ShareNotifyJob.new(generic_file.id))
    end

    def delete_from_share
      Sufia.queue.push(ShareNotifyDeleteJob.new(generic_file.id))
    end

    def send_message(access, recipient = nil)
      return if recipient.nil?
      User.batchuser.send_message(
        recipient,
        "You can now #{access} file #{generic_file.title}",
        "Permission change notification"
      )
    end
end
