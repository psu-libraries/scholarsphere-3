require 'scholarsphere/jobs/content_depositor_change_event_job'

class ProxyDepositRequest < ActiveRecord::Base
  include Blacklight::SolrHelper

  belongs_to :receiving_user, class_name: 'User'
  belongs_to :sending_user, class_name: 'User'

  validates :sending_user, :pid, presence: true
  validate :transfer_to_should_be_a_valid_username
  validate :sending_user_should_not_be_receiving_user

  after_save :send_request_transfer_message

  attr_reader :transfer_to

  def transfer_to=(key)
    @transfer_to = key
    self.receiving_user = User.find_by_user_key(key)
  end

  def transfer_to_should_be_a_valid_username
    errors.add(:transfer_to, "must be an existing user") unless receiving_user
  end

  def sending_user_should_not_be_receiving_user
    errors.add(:sending_user, 'must specify another user to receive the file') if receiving_user and receiving_user.user_key == sending_user.user_key
  end

  def send_request_transfer_message
    message = "#{sending_user.user_key} wants to transfer a file to you. Review all <a href='#{Rails.application.routes.url_helpers.transfers_path}'>transfer requests</a>"
    User.batchuser.send_message(receiving_user, message, "Ownership Change Request")
  end

  def pending?
    self.status == 'pending'
  end

  def transfer!
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
    query = ActiveFedora::SolrService.construct_query_for_pids([pid])
    solr_response = ActiveFedora::SolrService.query(query, :raw => true)
    SolrDocument.new(solr_response['response']['docs'].first, solr_response)
  end
end
