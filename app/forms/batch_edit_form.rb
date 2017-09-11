# frozen_string_literal: true

class BatchEditForm < Sufia::Forms::BatchEditForm
  include WithCreator
  include WithCleanerAttributes

  def self.build_permitted_params
    permitted = super
    permitted << { creators: [:id, :first_name, :last_name, :_destroy] }
    permitted << :visibility
    permitted
  end

  def model_class_name
    'batch_edit_item'
  end

  def creators
    # The model.creators association doesn't seem to work
    # properly with an unpersisted record, so we manually load
    # the creator records here.
    if model.new_record? && model.creator_ids.present?
      person_records = Person.find model.creator_ids
      model.creators = person_records
    end
    super
  end
end
