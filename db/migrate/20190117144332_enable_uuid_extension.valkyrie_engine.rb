# This migration comes from valkyrie_engine (originally 20160111215816)
# frozen_string_literal: true
class EnableUuidExtension < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp'
  end
end
