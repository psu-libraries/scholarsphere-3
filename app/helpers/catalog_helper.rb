module CatalogHelper
  # we're forced to have this method because blacklight's add_facet_field doesn't
  # take in a Proc
  def titleize(str)
    str.titleize
  end

  def gallery?
    document_index_view_type == :gallery
  end
end
