module Transferable
  extend ActiveSupport::Concern

  included do
    delegate :proxy_depositor, :to=>:properties, :unique => true

    attr_accessor :transfer_to
    attr_writer :proxy_for_user
    #validates :proxy_for_user, presence: {message: "Unable to find the user"}, if: :proxy_for
    validate :proxy_for_should_be_a_valid_username
    after_save :request_transfer, if: :transfer_to
  end


  def proxy_for_user
    @proxy_for_user ||= User.find_by_user_key(transfer_to)
  end

  def proxy_for_should_be_a_valid_username
    return unless transfer_to
    errors.add(:transfer_to, "must be an existing user") unless proxy_for_user
  end

  def request_transfer
    request_transfer_to(proxy_for_user)
  end


  # @param [User] target Who this generic file should get transfered to
  def request_transfer_to(target)
    raise ArgumentError, "Must provide a target" unless target
    deposit_user = User.find_by_user_key(depositor)
    ProxyDepositRequest.create!(pid: pid, receiving_user: target, sending_user: deposit_user)
    message = "#{depositor} wants to transfer a file to you.\nClick here: to review it: #{Rails.application.routes.url_helpers.transfers_path}"
    User.batchuser.send_message(target, message, "#{depositor} wants to transfer a file to you")
  end

end
