# This migration comes from curation_concerns (originally 20170308175556)
class AddAllowsAccessGrantToWorkflow < ActiveRecord::Migration
  def change
    add_column :sipity_workflows, :allows_access_grant, :boolean
  end
end
