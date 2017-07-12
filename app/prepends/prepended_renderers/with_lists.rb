# frozen_string_literal: true
# Overrides CurationConcerns::Renderers::AttributeRenderer so that we can override tables
# with lists for relationships and descriptions.
module PrependedRenderers
  module WithLists
    # Create definition terms and descriptions for the attribute
    def render
      markup = []

      return '' if !values.present? && !options[:include_empty]
      markup << %(<dt class="attribute-term">#{label}</dt>)
      attributes = microdata_object_attributes(field).merge(class: "attribute #{field}")
      Array(values).each do |value|
        markup << "<dd#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</dd>"
      end
      markup.join.html_safe
    end
  end
end
