# frozen_string_literal: true

require 'byebug'

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
    expire_generic_works(embargo_expirations, :expire_generic_work_embargo )
    expire_generic_works(lease_expirations, :expire_generic_work_lease)
  end

  private
  
    def expire_generic_works(expired_works, expiration_method)
      expired_works.each do |expired_generic_work|
        send(expiration_method, expired_generic_work)
        expired_generic_work.save
        VisibilityCopyJob.perform_later(expired_generic_work)
      end
    end


    def expire_generic_work_embargo( expired_generic_work )
      expired_generic_work.visibility = expired_generic_work.embargo.visibility_after_embargo
      expired_generic_work.deactivate_embargo!
      expired_generic_work.embargo.save
    end

    def expire_generic_work_lease( expired_generic_work)
      expired_generic_work.visibility = expired_generic_work.lease.visibility_after_lease
      expired_generic_work.deactivate_lease!
      expired_generic_work.lease.save
    end

    def embargo_expirations
      generic_works_needing_embargo = GenericWork.where("embargo_release_date_dtsi:#{RSolr.solr_escape(expiration_date)}")
      generic_works_needing_embargo.select {|gw| gw.embargo.active?}
    end

    def lease_expirations
      generic_works_needing_lease = GenericWork.where("lease_expiration_date_dtsi:#{RSolr.solr_escape(expiration_date)}")
      generic_works_needing_lease.select {|gw| gw.lease.active?}
    end
end
