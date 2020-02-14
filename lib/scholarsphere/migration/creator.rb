# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Creator
      attr_reader :creator_alias

      def initialize(creator_alias)
        @creator_alias = creator_alias
      end

      delegate :email, :given_name, :sur_name, :psu_id, to: :agent

      def metadata
        {
          alias: creator_alias.display_name,
          creator_attributes: {
            email: email,
            given_name: given_name,
            surname: sur_name,
            psu_id: psu_id
          }
        }
      end

      private

        def agent
          @agent ||= (creator_alias.agent || agent_from_display_name)
        end

        def agent_from_display_name
          parsed_name = Namae::Name.parse(creator_alias.display_name)
          Agent.new(sur_name: parsed_name.family, given_name: parsed_name.given)
        end
    end
  end
end
