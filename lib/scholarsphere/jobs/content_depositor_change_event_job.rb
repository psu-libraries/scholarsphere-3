class ContentDepositorChangeEventJob
  def queue_name
    :proxy_deposit
  end

  attr_accessor :pid, :login

  def initialize(pid, login)
    self.pid = pid
    self.login = login
  end

  def run
    file = GenericFile.find(pid)
    file.proxy_depositor = file.depositor
    # TODO: Determine whether this should retain or reset permissions
    file.apply_depositor_metadata(login)
    file.save!
  end
end
