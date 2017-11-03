# frozen_string_literal: true

module HasCreators
  extend ActiveSupport::Concern

  included do
    ordered_aggregation :creators,
                    has_member_relation: ::RDF::Vocab::DC11.creator,
                    class_name: 'Alias',
                    type_validator: type_validator,
                    through: :list_source
    alias_method :creator, :creators

    def creators=(values)
      values = values.values if values.is_a? Hash
      agent_records = values.map { |v| AliasManagementService.call(v) }
      super(agent_records)
    end
  end
end
