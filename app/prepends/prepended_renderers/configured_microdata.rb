# frozen_string_literal: true

# Overrides CurationConcerns::Renderers::AttributeRenderer so we can correctly determines
# if a key exists instead of attempting to return a false value because I18n no longer
# interprets these as booleans.
module PrependedRenderers
  module ConfiguredMicrodata
    def microdata?(field)
      return false unless CurationConcerns.config.display_microdata

      key = "curation_concerns.schema_org.#{field}.property"
      t(key) if I18n.exists?(key)
    end

    def microdata_object?(field)
      return false unless CurationConcerns.config.display_microdata

      key = "curation_concerns.schema_org.#{field}.type"
      t(key) if I18n.exists?(key)
    end
  end
end
