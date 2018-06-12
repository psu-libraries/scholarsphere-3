# frozen_string_literal: true

# Translate the DOI from a DOI formatted value into a clickable link for the users
#  doi:blah => https://doi.org/blah
#
class TranslatedDoiRenderer < CurationConcerns::Renderers::ExternalLinkAttributeRenderer
  def li_value(value)
    if value.start_with?('doi:')
      value = value.gsub('doi:', 'https://doi.org/')
    end
    super(value)
  end
end
