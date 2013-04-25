class ProxyDepositRequest < ActiveRecord::Base
  belongs_to :receiving_user, class_name: 'User'
  belongs_to :sending_user, class_name: 'User'
  
  include Blacklight::SolrHelper

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
