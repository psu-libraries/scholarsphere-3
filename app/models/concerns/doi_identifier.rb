# frozen_string_literal: true

module DoiIdentifier
  def doi
    return nil if identifier.blank?

    identifier.select { |id| id.include?('doi:') }
  end
end
