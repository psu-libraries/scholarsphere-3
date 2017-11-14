# frozen_string_literal: true

class BatchEditForm < Sufia::Forms::BatchEditForm
  include WithCreator
  include WithCleanerAttributes

  def model_class_name
    'batch_edit_item'
  end

  def initialize_combined_fields
    super
    permissions = []
    admin_set_id = ''
    batch_document_ids.each do |doc_id|
      work = model_class.find(doc_id)
      permissions = (permissions + work.permissions).uniq
      admin_set_id = work.admin_set_id
    end
    model.admin_set_id = admin_set_id
    model.permissions_attributes = permissions.map(&:to_hash).uniq
  end
end
