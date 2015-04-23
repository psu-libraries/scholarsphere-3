class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior

  prepend_before_filter only: [:show, :edit] do  
    handle_legacy_url_prefix { |new_id| redirect_to collections.collection_path(new_id), status: :moved_permanently }
  end 

  def presenter_class
    ::CollectionPresenter
  end

  def form_class
    ::CollectionEditForm
  end

  # override the show to set the size via the solr documents instead of the document bytes, which load the content
  def show
    super
    pres = presenter
    pres.size =  member_docs.reduce(0) { |total, doc| total += doc[file_size_field].blank? ? 0: doc[file_size_field][0].to_f }
    pres
  end

  def collection_size_search_builder
    @collection_size_search_builder ||= CollectionSizeSearchBuilder.new([:include_collection_ids, :add_paging_to_solr], self)
  end


  def member_docs
    rows = collection.member_ids.count
    save_max = set_permissions_for_size_query(rows)
    query = collection_size_search_builder.start(0).rows(rows).query({ fl:[file_size_field]})
    resp = query_documents(query)
    reset_permissions_from_size_query(save_max)
    resp.documents
  end

  def query_documents (query)
    repository.search(query)
  end

  def file_size_field
    Solrizer.solr_name(:file_size, :symbol)
  end

  def set_permissions_for_size_query(rows)
    save_max = blacklight_config.max_per_page # ignore the max since we are only getting one field
    blacklight_config.max_per_page = rows
    save_max
  end

  def reset_permissions_from_size_query(max)
    blacklight_config.max_per_page = max # reset the max
  end

end
