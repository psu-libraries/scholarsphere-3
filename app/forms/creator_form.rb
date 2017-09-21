# frozen_string_literal: true

class CreatorForm
  attr_reader :person_alias

  delegate :id, :display_name, to: :person_alias

  # @param [Alias]
  def initialize(person_alias)
    @person_alias = person_alias
  end

  def read_only?
    person_alias.person.present?
  end

  def sur_name
    if read_only?
      person_alias.person.sur_name
    else
      parsed_name.family
    end
  end

  def given_name
    if read_only?
      person_alias.person.given_name
    else
      parsed_name.given
    end
  end

  def psu_id
    return unless read_only?
    person_alias.person.psu_id
  end

  def email
    return unless read_only?
    person_alias.person.email
  end

  def orcid_id
    return unless read_only?
    person_alias.person.orcid_id
  end

  private

    def parsed_name
      @parsed_name ||= Namae::Name.parse(display_name)
    end
end
