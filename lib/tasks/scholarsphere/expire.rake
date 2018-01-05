# frozen_string_literal: true

namespace :scholarsphere do
  namespace :expire do
    desc 'Expire any leases and embargoes (default date is today)'
    task :leases_and_embargoes, [:date] => [:environment] do |_t, args|
      date = args.fetch(:date, nil)
      expiration_date = if date
                          Date.parse(date)
                        else
                          Time.zone.today
                        end
      ExpirationService.call(expiration_date)
    end
  end
end
