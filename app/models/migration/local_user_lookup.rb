# frozen_string_literal: true

module Migration
  class LocalUserLookup
    class << self
      def find_users(user_name)
        user = user_by_id(user_name)
        return [user] if user.present?

        query_parts = name_to_query_parts(user_name)
        query = name_query(query_parts.count)
        User.where(query, *query_parts)
      end

      private

        def user_by_id(id)
          User.find_by(login: id)
        end

        def name_to_query_parts(name)
          name_to_parts(name).map do |part|
            "%#{handle_initial(part)}%"
          end
        end

        def name_query(query_parts_count)
          Array.new(query_parts_count, 'UPPER(display_name) like ?')
            .join(' AND ')
        end

        def name_to_parts(name)
          name_parts = name.split(' ').map(&:upcase)
          name_parts.map { |part| part.gsub(',', '').gsub('.', '') }
        end

        def handle_initial(part)
          return part if part.length > 1
          " #{part}"
        end
      end
  end
end
