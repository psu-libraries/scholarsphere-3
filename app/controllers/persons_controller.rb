# frozen_string_literal: true

class PersonsController < ApplicationController
  protect_from_forgery with: :null_session

  def name_query
    authorize! :name_query, Alias
    render json: search_results(params['q'])
  end

  private

    def search_results(query)
      aliases = ActiveFedora::SolrService.query(
        "display_name_tesim:#{query}*",
        fq: 'has_model_ssim:Alias',
        fl: ['id', 'display_name_tesim', 'name_ssim'],
        qt: 'select',
        rows: 10
      )
      aliases.each do |person_alias|
        person = ActiveFedora::SolrService.query(
          "id:#{person_alias['name_ssim'].first}",
          fl: ['given_name_tesim', 'sur_name_tesim', 'email_ssim', 'psu_id_ssim', 'orcid_id_ssim']
        )
        person_alias.merge!(person.first)
      end
    end
end
