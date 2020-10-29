# frozen_string_literal: true

module Scholarsphere::Migration
  class DepositorsReport
    attr_reader :logins, :depositors

    # @param [Array<String>] logins for each depositor
    def initialize(*user_ids)
      @depositors = Hash.new
      @missing = Hash.new
      build_list(user_ids)
    end

    def missing
      depositors.select { |_login, results| results[:psu_id].empty? }.keys.each do |login|
        @missing[login] ||= find_missing_agents(login)
      end
      @missing
    end

    def missing_depositors_report
      File.open('missing_depositors.json', 'w') { |file| file.write(@missing.to_json) }
    end

    private

      def build_list(ids)
        if ids.empty?
          all_depositors
        else
          ids.map { |login| depositors[login] = agents_for_login(login) }
        end
      end

      def all_depositors
        ActiveFedora::SolrService.query('depositor_ssim:*', fl: ['depositor_ssim'], rows: 100000).map do |hit|
          login = hit['depositor_ssim'].first
          depositors[login] ||= agents_for_login(login)
        end
      end

      def agents_for_login(login)
        results = Hash.new

        results[:psu_id] = Agent.where(psu_id: login).map(&:attributes)
        results[:email] = Agent.where(email: "#{login}@psu.edu").map(&:attributes)

        user = User.find_by(login: login)
        parsed_name = Namae.parse(user.display_name)
        if parsed_name.present?
          results[:full_name] = Agent.where(
            sur_name: parsed_name.first.family,
            given_name: parsed_name.first.given
          ).map(&:attributes)
        end
        results
      end

      def find_missing_agents(login)
        user = User.find_by(login: login)
        works = GenericWork.where(depositor: login)
        collections = ::Collection.where(depositor: login)
        agents = (works + collections).map(&:creators).flatten.map(&:agent_id).uniq.map { |id| Agent.find(id) }
        agent_names = agents.map do |agent|
          {
            id: agent.id,
            given_name: agent.given_name,
            sur_name: agent.sur_name,
            psu_id: agent.psu_id,
            email: agent.email
          }
        end
        { user: user.display_name, agents: agent_names, works: works.count, collections: collections.count }
      end
  end
end
