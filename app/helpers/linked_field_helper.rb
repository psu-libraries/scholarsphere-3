module LinkedFieldHelper

  def render_linked_field(value, link_function, opt_param)
    return link_function.call value if opt_param.blank?
    return link_function.call value, opt_param unless link_function.name == :link_to_field
    return link_function.call opt_param, value
  end
end
