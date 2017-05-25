# frozen_string_literal: true
class FileSetDerivativeFailureJob < FileSetAttachedEventJob
  def action
    "The derivative for #{link_to repo_object.title.first, polymorphic_path(repo_object)} was not successfully created"
  end
end
