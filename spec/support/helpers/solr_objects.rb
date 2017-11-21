# frozen_string_literal: true

def conn
  ActiveFedora::SolrService.instance.conn
end

# @param [Collection] collection
# @param [String] creator
# @note allows you to save a collection to Solr using a creator as a string
def save_collection_to_solr(collection, creator)
  allow(Collection).to receive(:find).with(collection.id).and_return(collection)
  allow(collection).to receive(:creator_ids).and_return([creator])
  allow(collection).to receive(:creators).and_return([])
  conn.add document_with_original_creator(collection.to_solr, creator)
  conn.commit
end

# @param [GenericWork] work
# @param [String] creator
# @note allows you to save a work to Solr using a creator as a string
def save_work_to_solr_and_fake_fedora(work, creator)
  allow(GenericWork).to receive(:find).with(work.id).and_return(work)
  allow(work).to receive(:creator).and_return(Array(creator).shuffle)
  allow(work).to receive(:reload).and_return(work)
  conn.add document_with_original_creator(work.to_solr, creator)
  conn.commit
end

def document_with_original_creator(document, creator)
  document.merge!('creator_tesim' => creator)
end
