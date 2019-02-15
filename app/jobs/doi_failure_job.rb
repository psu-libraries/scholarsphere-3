# frozen_string_literal: true

class DOIFailureJob < ContentEventJob
  def action
    'DOI failed to mint for this work'
  end
end
