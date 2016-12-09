# frozen_string_literal: true
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  ##
  # Render the thumbnail, if available, for a document and
  # link it to the document record.
  #
  # @param [SolrDocument] document
  # @param [Hash] image_options to pass to the image tag
  # @param [Hash] url_options to pass to #link_to_document
  # @return [String]
  def render_thumbnail_tag(document, image_options = {}, url_options = {})
    image_options[:alt] = ""
    image_options["aria-hidden"] = true
    value = if blacklight_config.view_config(document_index_view_type).thumbnail_method
              send(blacklight_config.view_config(document_index_view_type).thumbnail_method, document, image_options)
            elsif blacklight_config.view_config(document_index_view_type).thumbnail_field
              url = thumbnail_url(document)

              image_tag url, image_options if url.present?
            end

    if value
      if url_options == false || url_options[:suppress_link]
        value
      else
        link_to_document document, value, url_options
      end
    end
  end
end
