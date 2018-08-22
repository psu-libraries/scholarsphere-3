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
      Rails.logger.error 'Unable to reach TermsComponent via Solr connection. Is it enabled in your solr config?'
      return []
    end

    Sufia::Statistics::TermQuery::Result.build(json['terms'][term])
  end
end
