# frozen_string_literal: true

module SufiaHelper
  include ::BlacklightHelper
  include CurationConcerns::MainAppHelpers
  include Sufia::BlacklightOverride
  include Sufia::SufiaHelperBehavior

  def collection_search_parameters?
    params[:cq].present?
  end

  def help_icon
    content_tag 'span', nil, 'aria-hidden' => true, class: 'help-icon'
  end

  def should_render_index_field?(document, field_config)
    return false if document_index_view_type == :gallery
    super
  end

  # we're forced to have this method because blacklight's add_facet_field doesn't
  # take in a Proc
  def titleize(str)
    str.titleize
  end
end
