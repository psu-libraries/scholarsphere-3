module PermissionHelper
  def permission_level_tag(document)
    if document.registered?
      value = t('sufia.institution_name')
      className = "label-info"
    elsif document.public?
      value = "Open Access"
      className = "label-success"
    else
      value = "Private"
      className = "label-danger"
    end
    if can? :edit, document
      path = sufia.edit_generic_file_path(document, tab: "permissions")
    else
      path = sufia.generic_file_path(document)
    end
    link_to content_tag(:span, value, class: "label #{className}", title: value), path, id: "permission_#{document.id}"
  end
end
