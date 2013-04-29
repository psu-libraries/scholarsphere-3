module ApplicationHelper

  # Renders a count value for facet limits. Can be over-ridden locally
  # to change style, for instance not use parens. And can be called
  # by plugins to get consistent display. 
  def render_facet_count(num)
    pnum = "("+ num.to_s() + ")"
    content_tag("span", t('blacklight.search.facets.count', :number => pnum), :class => "ss-count") 
  end


  # TODO move to sufia
  def error_messages_for(object)
    if object.try(:errors) and object.errors.full_messages.any?
      content_tag(:div, :class => 'alert alert-block alert-error validation-errors') do
        content_tag(:h4, I18n.t('sufia.errors.header', :model => object.class.model_name.human.downcase), :class => 'alert-heading') +
        content_tag(:ul) do
          object.errors.full_messages.map do |message|
            content_tag(:li, message)
          end.join('').html_safe
        end
      end
    else
      '' # return empty string
    end
  end
  
  
end

