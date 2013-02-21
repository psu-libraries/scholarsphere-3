module ApplicationHelper

  # Renders a count value for facet limits. Can be over-ridden locally
  # to change style, for instance not use parens. And can be called
  # by plugins to get consistent display. 
  def render_facet_count(num)
    pnum = "("+ num.to_s() + ")"
    content_tag("span", t('blacklight.search.facets.count', :number => pnum), :class => "ss-count") 
  end
  
end

