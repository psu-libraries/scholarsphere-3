# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Depositor
      attr_reader :user, :agent, :person

      NullDepositor = Struct.new(:login) do
        attr_reader :email, :display_name
      end

      NullAgent = Struct.new(:login) do
        attr_reader :email, :given_name, :sur_name
      end

      NullPerson = Struct.new(:login) do
        attr_reader :university_email, :given_name, :family_name
      end

      def initialize(login:)
        @user = User.find_by(login: login) || NullDepositor.new(login)
        @agent = Agent.where(psu_id: login).append(NullAgent.new(login)).first
        @person = PennState::SearchService::Client.new.userid(login) || NullPerson.new(login)
      end

      def metadata
        {
          psu_id: user.login,
          email: person.university_email || agent.email || user.email,
          given_name: person.given_name || agent.given_name || given_name,
          surname: person.family_name || agent.sur_name || surname
        }
      end

      private

        def given_name
          return if parsed_display_name.family.nil?

          parsed_display_name.given
        end

        def surname
          parsed_display_name.family || parsed_display_name.given || user.login
        end

        def parsed_display_name
          @parsed_display_name ||= Namae.parse(user.display_name).append(Namae::Name.new).first
        end
    end
  end
end
