class CollectionEditForm < Sufia::Forms::CollectionEditForm
  include HydraEditor::Form

  self.terms = [:title, :description, :creator]
end
