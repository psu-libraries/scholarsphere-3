# frozen_string_literal: true

class ExpirationService
  attr_reader :expiration_date

  # @param [Date] date the date by which to measure expirations. Defaults to today.
  def self.call(date = Time.zone.today)
    new(date).run
  end

  # Set the expiration data such that it can be used in a solr query
  def initialize(date)
    @expiration_date = date.strftime('%Y-%m-%dT00:00:00Z')
  end

  def run
    expire_embargoes
    expire_leases
  end

  def expire_embargoes
    embargo_expirations.each do |expiration|
      next unless expiration.embargo.active?
      expiration.visibility = expiration.embargo.visibility_after_embargo
      expiration.deactivate_embargo!
      expiration.embargo.save
      expiration.save
      VisibilityCopyJob.perform_later(expiration)
    end
  end

  def expire_leases
    lease_expirations.each do |expiration|
      next unless expiration.lease.active?
      expiration.visibility = expiration.lease.visibility_after_lease
      expiration.deactivate_lease!
      expiration.lease.save
      expiration.save
      VisibilityCopyJob.perform_later(expiration)
    end
  end

  def embargo_expirations
    GenericWork.where("embargo_release_date_dtsi:#{RSolr.solr_escape(expiration_date)}")
  end

  def lease_expirations
    GenericWork.where("lease_expiration_date_dtsi:#{RSolr.solr_escape(expiration_date)}")
  end
end
