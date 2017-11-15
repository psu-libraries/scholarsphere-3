# frozen_string_literal: true

class AgentsController < ApplicationController
  protect_from_forgery with: :null_session

  def name_query
    authorize! :name_query, Alias
    render json: search_results(params['q'])
  end

  private

    def search_results(query)
      solr_search_results(query)
    end

    # returns solr results in the following format
    # [{"id"=>"c25dd3ac-518c-428f-96e1-6ce39448c88d",
    #   "name_ssim"=>["6edd992f-2ed8-4e5e-9908-31812427be87"],
    #   "display_name"=>["Cole Carolyn Ann"],
    #   "given_name"=>["CAROLYN ANN"],
    #   "sur_name"=>["COLE"],
    #   "psu_id"=>["cam156"],
    #   "email"=>["cam156@psu.edu"]}]
    def solr_search_results(query)
      aliases = solr_aliases(query)
      aliases.each do |agent_alias|
        add_agent_information_to_alias(agent_alias)
        clean_agent_alias_keys(agent_alias)
      end
    end

    def solr_aliases(query)
      ActiveFedora::SolrService.query(
        "display_name_tesim:#{query}*",
          fq: 'has_model_ssim:Alias',
          fl: ['id', 'display_name_tesim', 'name_ssim'],
          qt: 'select',
          rows: 10
      )
    end

    def add_agent_information_to_alias(agent_alias)
      agent = ActiveFedora::SolrService.query(
        "id:#{agent_alias['name_ssim'].first}",
          fl: ['given_name_tesim', 'sur_name_tesim', 'email_ssim', 'psu_id_ssim', 'orcid_id_ssim']
      )
      agent_alias.merge!(agent.first)
    end

    def clean_agent_alias_keys(agent_alias)
      agent_alias['given_name'] = agent_alias.delete('given_name_tesim')
      agent_alias['sur_name'] = agent_alias.delete('sur_name_tesim')
      agent_alias['email'] = agent_alias.delete('email_ssim')
      agent_alias['psu_id'] = agent_alias.delete('psu_id_ssim')
      agent_alias['orcid_id'] = agent_alias.delete('orcid_id_ssim')
      agent_alias['display_name'] = agent_alias.delete('display_name_tesim')
    end
end
