# frozen_string_literal: true

class NameDisambiguationService
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def disambiguate
    return PsuDir::Disambiguate::Name.disambiguate(name)
  rescue RuntimeError, Mail::Field::ParseError, Net::LDAP::FilterSyntaxInvalidError => e
    Rails.logger.warn "Error processing #{name}  #{e}"
    return []
  end
end
