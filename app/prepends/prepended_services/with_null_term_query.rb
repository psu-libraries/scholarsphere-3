# frozen_string_literal: true

# Overrides Sufia::Statistics::TermQuery to correct for term queries that have no results

module PrependedServices::WithNullTermQuery
  def query
    term = index_key
    # Grab JSON response (looks like {"terms": {"depositor_tesim": {"mjg36": 3}}} for depositor)
    json = solr_connection.get 'terms', params: { 'terms.fl' => term,
                                                  'terms.sort' => 'count',
                                                  'terms.limit' => @limit,
                                                  wt: 'json',
                                                  'json.nl' => 'map',
                                                  omitHeader: 'true' }
    if json.blank?
      Rails.logger.error "Solr returned an empty response for term query #{term}. Is it configured correctly?"
      return []
    end

    Sufia::Statistics::TermQuery::Result.build(json['terms'][term])
  rescue StandardError => exception
    Rails.logger.error "Unable to query Solr for the term #{term}: #{exception}"
    return []
  end
end
