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

  private

    def expire_embargoes
      expire_works(works_with_expired_active_embargo) do |work|
        expire_work_embargo(work)
      end
    end

    def expire_leases
      expire_works(works_with_expired_active_lease) do |work|
        expire_work_lease(work)
      end
    end

    def expire_works(expired_works)
      expired_works.each do |expired_work|
        yield(expired_work)
        expired_work.save
        VisibilityCopyJob.perform_later(expired_work)
      end
    end

    def expire_work_embargo(expired_work)
      expired_work.visibility = expired_work.embargo.visibility_after_embargo
      expired_work.deactivate_embargo!
      expired_work.embargo.save
    end

    def expire_work_lease(expired_work)
      expired_work.visibility = expired_work.lease.visibility_after_lease
      expired_work.deactivate_lease!
      expired_work.lease.save
    end

    def works_with_expired_active_embargo
      works_expired_embargo = GenericWork.where("embargo_release_date_dtsi:#{RSolr.solr_escape(expiration_date)}")
      works_expired_embargo.select { |gw| gw.embargo.active? }
    end

    def works_with_expired_active_lease
      generic_works_needing_lease = GenericWork.where("lease_expiration_date_dtsi:#{RSolr.solr_escape(expiration_date)}")
      generic_works_needing_lease.select { |gw| gw.lease.active? }
    end
end
