module Export
  class Permissions
    attr_accessor :permissions

    class Permission
      attr_accessor :id, :agent, :mode, :access_to
      def initialize(permission)
        @id = permission.id
        @agent = permission.agent.first.rdf_subject.to_s
        @mode = permission.mode.first.rdf_subject.to_s
        # Using .id instead of .uri allows us to rebuild the URI later on with a new base URI
        @access_to = permission.access_to.id
      end
    end

    def initialize(permissions)
      @permissions = permissions
    end

    def to_a
      @permissions.map { |p| Permission.new(p) }
    end
  end
end
