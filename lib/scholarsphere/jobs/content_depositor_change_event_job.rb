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
    file.depositor = login
    # NOTE: we could be erasing any edit permissions the depositor previously established.
    file.edit_users = [login]
    file.save!
  end
end
