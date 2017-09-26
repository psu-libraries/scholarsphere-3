# frozen_string_literal: true

# TODO: When upgrading to Sufia 7, this should extend Sufia::MessageUserService
class PermissionsChangeService
  attr_reader :state, :generic_work

  # @param [PermissionsChangeSet] permission_state hash representing changes in permissions
  # @param [GenericWork] generic_work whose permissions have been changed
  def initialize(permission_state, generic_work)
    @state = permission_state
    @generic_work = generic_work
  end

  def call
    return if state.unchanged?
    inform_users
    update_share_notify
  end

  def inform_users
    state.added.each do |permission|
      next unless permission[:type] == 'person'
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
      ResourceFilteredList.new([generic_work]).filter.empty?
    end

    def send_to_share
      ShareNotifyJob.perform_later(generic_work)
    end

    def delete_from_share
      ShareNotifyDeleteJob.perform_later(generic_work.id)
    end

    def send_message(access, recipient = nil)
      return if recipient.nil?
      User.batchuser.send_message(
        recipient,
        "You can now #{access} file #{generic_work.title}",
        'Permission change notification'
      )
    end
end
