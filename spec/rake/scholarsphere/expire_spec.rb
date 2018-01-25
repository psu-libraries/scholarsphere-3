# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'scholarsphere:expire' do
  before do
    load_rake_environment ["#{Rails.root}/lib/tasks/scholarsphere/expire.rake"]
  end

  describe ':leases_and_embargoes' do
    context 'by default' do
      it 'expires any leases and embargoes from today' do
        expect(ExpirationService).to receive(:call).with(Time.zone.today)
        run_task('scholarsphere:expire:leases_and_embargoes')
      end
    end

    context 'with a specific date' do
      it 'expires any leases and embargoes from today' do
        expect(ExpirationService).to receive(:call).with(Date.parse('12/12/20'))
        run_task('scholarsphere:expire:leases_and_embargoes', '12/12/20')
      end
    end
  end
end
