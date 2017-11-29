# frozen_string_literal: true

module Migration
  class CreatorMigrator
    class << self
       def run(alias_cache_file = 'tmp/creator_alias_cache.json')
         creator_list = Migration::CreatorList.new(alias_cache_file)
         alias_hash = creator_list.to_alias_hash
         Migration::SolrListMigrator.migrate_creators(Migration::SolrWorkList.new, alias_hash)
         Migration::SolrListMigrator.migrate_creators(Migration::SolrCollectionList.new, alias_hash)
       end
    end
  end
end
