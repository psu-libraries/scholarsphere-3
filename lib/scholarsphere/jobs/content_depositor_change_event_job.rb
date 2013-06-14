class ContentDepositorChangeEventJob
  def queue_name
    :proxy_deposit
  end

  attr_accessor :pid, :login, :reset

  # @param [String] pid identifier of the file to be transfered
  # @param [String] login the user key of the user the file is being transfered to.
  # @param [Boolean] reset (false) should the access controls be reset. This means revoking edit access from the depositor
  def initialize(pid, login, reset=false)
    self.pid = pid
    self.login = login
    self.reset = reset
  end

  def run
    file = GenericFile.find(pid)
    file.proxy_depositor = file.depositor
    file.rightsMetadata.clear_permissions! if reset
    # TODO: Determine whether this should retain or reset permissions
    file.apply_depositor_metadata(login)
    file.save!
  end
end
