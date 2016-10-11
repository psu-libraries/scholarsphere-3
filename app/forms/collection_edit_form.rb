# frozen_string_literal: true
class CollectionEditForm < Sufia::Forms::CollectionEditForm
  include HydraEditor::Form
  include HydraEditor::Form::Permissions

  self.model_class = ::Collection
  self.terms = [:title, :description, :creator, :visibility]
end
