class ProxyDepositRequest < ActiveRecord::Base
  belongs_to :receiving_user, class_name: 'User'
  belongs_to :sending_user, class_name: 'User'
  
  def transfer!()
    Sufia.queue.push(ContentDepositorChangeEventJob.new(pid, receiving_user.user_key))
    self.fulfillment_date= Time.now
    save!
  end

end
