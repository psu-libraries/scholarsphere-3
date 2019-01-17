# This migration comes from valkyrie_engine (originally 20170124135846)
# frozen_string_literal: true
class AddModelTypeToOrmResources < ActiveRecord::Migration[5.0]
  def change
    add_column :orm_resources, :resource_type, :string
  end
end
