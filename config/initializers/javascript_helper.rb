# frozen_string_literal: true

ActionView::Helpers::JavaScriptHelper::JS_ESCAPE_MAP['`'] = '\\`'
ActionView::Helpers::JavaScriptHelper::JS_ESCAPE_MAP['$'] = '\\$'

module ActionView::Helpers::JavaScriptHelper
  alias :old_ej :escape_javascript
  alias :old_j :j

  def escape_javascript(javascript)
    javascript = javascript.to_s
    result = if javascript.empty?
               ''
             else
               javascript.gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"']|[`]|[$])/u, JS_ESCAPE_MAP)
             end
    javascript.html_safe? ? result.html_safe : result
  end

  alias :j :escape_javascript
end
