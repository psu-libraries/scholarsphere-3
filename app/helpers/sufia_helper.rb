module SufiaHelper
  include ::BlacklightHelper
  include Sufia::BlacklightOverride
  include Sufia::SufiaHelperBehavior

  def should_render_index_field? document, field_config
    return false if document_index_view_type == :gallery
    super
  end

end
