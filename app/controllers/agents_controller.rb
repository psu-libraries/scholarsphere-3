# frozen_string_literal: true

class AgentsController < ApplicationController
  protect_from_forgery prepend: true, with: :null_session

  def name_query
    authorize! :name_query, Alias
    render json: search_results(params['q'])
  end

  private

    def search_results(query)
      ldap_results = ldap_search_results(query)
      solr_results = solr_search_results(query)
      merge_results(solr_results, ldap_results)
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

    # returns ldap results in the following format
    # [{"id"=>nil,
    #   "display_name"=>["Cole Carolyn Ann"],
    #   "given_name"=>["CAROLYN ANN"],
    #   "sur_name"=>["COLE"],
    #   "psu_id"=>["cam156"],
    #   "email"=>["cam156@psu.edu"]}]
    def ldap_search_results(query)
      name = Namae::Name.parse(query.upcase)

      email_items = PsuDir::Disambiguate::User.query_ldap_by_mail(query + '@psu.edu', ldap_attrs) || []
      name_items = PsuDir::Disambiguate::User.query_ldap_by_name(name.given, "#{name.family}*", ldap_attrs) || []

      # each item looks like {:id=>"jwr108", :given_name=>"JAMES W.", :surname=>"ROUNCE", :email=>"jwr108@psu.edu", :affiliation=>["STAFF"], :displayname=>"JAMES W. ROUNCE"}
      (email_items + name_items).map do |ldap_entry|
        {
          'id' => nil,
          'given_name' => ldap_entry[:given_name],
          'sur_name' => ldap_entry[:surname],
          'email' => ldap_entry[:mail],
          'psu_id' => ldap_entry[:id],
          'orcid_id' => nil,
          'display_name' => ldap_entry[:displayname]
        }
      end
    end

    def merge_results(main_results, additional_results)
      main_result_hash = {}
      main_results.each { |result| main_result_hash[hash_key(result)] = result }
      additional_results.each do |result|
        if main_result_hash[hash_key(result)].blank?
          main_results << result
          main_result_hash[hash_key(result)] = result
        end
      end

      main_results.sort { |x, y| hash_key(y) <=> hash_key(x) }
    end

    def hash_key(result)
      display_name = hash_part(result['display_name'])
      email = hash_part(result['email'])
      "#{display_name}; #{email}"
    end

    def hash_part(result_item)
      result_item = result_item.first if result_item.is_a?(Array)
      result_item = result_item.downcase if result_item.present?
      result_item
    end

    def solr_aliases(query)
      query_parts = query.split(' ').map { |q_part| "display_name_tesim:#{q_part}" }

      ActiveFedora::SolrService.query(
        "#{query_parts.join(' AND ')}*",
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

    def ldap_attrs
      [:uid, :givenname, :sn, :mail, :eduPersonPrimaryAffiliation, :displayname]
    end
end
