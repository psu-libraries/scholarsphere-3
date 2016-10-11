class DropLocalAuthorities < ActiveRecord::Migration
  def change
    drop_table :local_authority_entries
    drop_table :local_authorities
    drop_table :domain_terms
    drop_table :domain_terms_local_authorities
  end
end
