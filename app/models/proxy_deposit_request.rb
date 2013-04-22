class ProxyDepositRequest < ActiveRecord::Base
  belongs_to :receiving_user, class_name: 'User'
  # attr_accessible :title, :body
  
  def transfer!()
    Sufia.queue.push(ContentDepositorChangeEventJob.new(pid, receiving_user.user_key))
    self.fulfilled_at= Time.now
    save!
  end

end
