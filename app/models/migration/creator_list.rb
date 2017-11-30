# frozen_string_literal: true

module Migration
  class CreatorList
    attr_reader :uniq_system_creators, :creator_alias_cache
    def initialize(creator_alias_cache = 'tmp/creator_alias_cache.json')
      @creator_alias_cache = creator_alias_cache
      @uniq_system_creators = find_uniq_system_creators
    end

    def to_alias_hash
      @agents ||= convert_to_aliases
    end

    private

      def find_uniq_system_creators
        creator_docs = ActiveFedora::SolrService.query('*:*', fq: 'has_model_ssim:GenericWork OR has_model_ssim:Collection', fl: 'creator_tesim', rows: 10000)
        creators = creator_docs.map { |doc| doc['creator_tesim'] }
        creators.flatten.uniq.reject(&:blank?).sort
      end

      def convert_to_aliases
        aliases = load_cache
        @uniq_system_creators.map do |creator|
          next if aliases.key?(creator)
          aliases[creator] = creator_to_alias(creator)
        end
        store_cache(aliases)
        aliases
      end

      def load_cache
        return {} unless File.exist?(creator_alias_cache)

        aliases = {}
        file = File.open(creator_alias_cache)
        lines = file.readlines
        lines.each do |line|
          creator, alias_id = line.strip.split(cache_separator)
          aliases[creator] = Alias.find(alias_id)
        end
        aliases
      end

      def store_cache(aliases)
        file = File.new(creator_alias_cache, 'w')
        aliases.each_pair do |current_creator, current_alias|
          file.puts("#{current_creator}#{cache_separator}#{current_alias.id}")
        end
        file.close
        aliases
      end

      def creator_to_alias(creator)
        users = LocalUserLookup.find_users(creator)
        if users.count == 1
          user = users[0]
          # validate creator against user
          # todo Not really sure what to do here
          # logger.warn("Matching #{creator} with #{user.display_name} #{user.login}")
          #
          # user_to_alias(user, creator)
          if validate_user(creator, user)
            logger.warn("Matching #{creator} with #{user.display_name} #{user.login}")
            user_to_alias(user, creator)
          else
            logger.warn("No match #{creator} with #{user.display_name} #{user.login} did not validate.  Creating new agent")
            name_to_alias(creator)
          end
        else
          name_to_alias(creator)
        end
      end

      def validate_user(creator, user)
        # id match is valid
        return true if creator == user.login

        logger.warn("Matching #{creator} with #{user.display_name} #{user.login}")
        valid_given_and_sur_name?(parse_name(user.display_name), parse_name(creator)) ||
          (comparable_name(creator) == comparable_name(user.display_name))
      end

      def valid_given_and_sur_name?(user_name, creator_name)
        # family name match is valid and the given name initial is at the start
        return false unless user_name.family.casecmp(creator_name.family.downcase).zero?
        return true if user_name.given == creator_name.given
        creator_name.given.present? && ((creator_name.given.size > 2) || user_name.given.downcase.start_with?(creator_name.given.downcase))
      end

      def comparable_name(name)
        name_parts = name.downcase.gsub(',', ' ').squeeze(' ').split(' ')
        comparable = Hash.new(0)
        name_parts.each { |v| comparable[v] += 1 }
        comparable
      end

      def name_to_alias(full_name)
        name = parse_name(full_name)
        AliasManagementService.call(display_name: full_name, given_name: name.given, sur_name: name.family)
      end

      def parse_name(full_name)
        name = Namae::Name.parse(full_name)
        if name.given.blank? || name.family.blank?
          name.family = full_name
          name.given = nil
        end
        name
      end

      def user_to_alias(user, creator)
        agent = Agent.where(psu_id: user.login).first
        if agent.blank?
          name = parse_name(user.display_name)
          agent = Agent.create(given_name: name.given, sur_name: name.family, psu_id: user.login, email: user.email)
        end
        agent_alias = Alias.where(display_name: creator, name_ssim: agent.id).first
        agent_alias ||= Alias.create(display_name: creator, agent: agent)
        agent_alias
      end

      def cache_separator
        '$$'
      end
  end
end
