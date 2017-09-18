# frozen_string_literal: true

def conn
  ActiveFedora::SolrService.instance.conn
end

def save_collection_to_solr(collection, creator)
  allow(Collection).to receive(:find).with(collection.id).and_return(collection)
  allow(collection).to receive(:creator_ids).and_return([creator])
  hash = collection.to_solr
  hash['creator_sim'] = creator
  conn.add hash
  conn.commit
end

def save_work_to_solr_and_fake_fedora(work, creator)
  allow(GenericWork).to receive(:find).with(work.id).and_return(work)
  allow(work).to receive(:creator_ids).and_return([creator])
  allow(work).to receive(:reload).and_return(work)
  hash = work.to_solr
  hash['creator_sim'] = creator
  conn.add hash
  conn.commit
end
