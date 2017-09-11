# frozen_string_literal: true

class PersonsController < ApplicationController
  protect_from_forgery with: :null_session

  def name_query
    authorize! :name_query, Person
    query = "has_model_ssim:Person AND (given_name_tesim:#{params['q']}* OR sur_name_tesim:#{params['q']}*)"
    render json: ActiveFedora::SolrService.query(query)
  end
end
