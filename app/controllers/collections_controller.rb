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

  def member_docs
    rows = @response["response"]["numFound"]
    save_max = blacklight_config.max_per_page # ignore the max since we are only getting one field
    blacklight_config.max_per_page = rows
    query = collection_member_search_builder.rows(rows).query({ fl:[file_size_field]})
    resp = query_documents(query)
    blacklight_config.max_per_page = save_max # reset the max
    resp.documents
  end

  def query_documents (query)
    repository.search(query)
  end

  def file_size_field
    Solrizer.solr_name(:file_size, :symbol)
  end
end
