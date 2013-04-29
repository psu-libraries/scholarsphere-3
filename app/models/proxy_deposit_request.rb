class ProxyDepositRequest < ActiveRecord::Base
  belongs_to :receiving_user, class_name: 'User'
  belongs_to :sending_user, class_name: 'User'
  
  validates :sending_user, :pid, presence: true

  include Blacklight::SolrHelper

  attr_reader :transfer_to
  validate :transfer_to_should_be_a_valid_username
  after_save :send_request_transfer_message
  
  def transfer_to= key
    @transfer_to = key
    self.receiving_user = User.find_by_user_key(key)
  end

  def transfer_to_should_be_a_valid_username
    errors.add(:transfer_to, "must be an existing user") unless receiving_user
  end

  def send_request_transfer_message
    message = "#{sending_user.user_key} wants to transfer a file to you.\nClick here: to review it: #{Rails.application.routes.url_helpers.transfers_path}"
    User.batchuser.send_message(receiving_user, message, "#{sending_user.user_key} wants to transfer a file to you")
  end



  def pending?
    self.status == 'pending'
  end

  def transfer!()
    Sufia.queue.push(ContentDepositorChangeEventJob.new(pid, receiving_user.user_key))
    self.status = 'accepted'
    self.fulfillment_date= Time.now
    save!
  end

  def reject!(comment = nil)
    self.receiver_comment = comment if comment
    self.status = 'rejected'
    self.fulfillment_date= Time.now
    save!
  end

  def cancel!
    self.status = 'canceled'
    self.fulfillment_date= Time.now
    save!
  end

  def solr_doc
    query =ActiveFedora::SolrService.construct_query_for_pids([pid])
    solr_response = ActiveFedora::SolrService.query(query, :raw=>true)
    SolrDocument.new(solr_response['response']['docs'].first, solr_response)
  end
end
