module ApplicationHelper
  def has_collection_search_parameters?
    !params[:cq].blank?
  end

  def collection_helper_method  value
    c = Collection.load_instance_from_solr(value)
    return c.title
  end
end
