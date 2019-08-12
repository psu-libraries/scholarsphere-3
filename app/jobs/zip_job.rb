# frozen_string_literal: true

class ZipJob < ApplicationJob
  queue_as :zip

  class Error < StandardError; end

  attr_reader :object

  def perform(id)
    @object = ActiveFedora::Base.find(id)
    file = ZipFile.new(ScholarSphere::Application.config.public_zipfile_directory.join("#{@object.id}.zip"))

    zip_service.new(@object, public_ability, file.parent, file.basename.to_s).call if file.stale?
  end

  def zip_service
    return WorkZipService if object.is_a?(GenericWork)
    return CollectionZipService if object.is_a?(Collection)

    raise Error, "#{object.class} is not exportable as a zip"
  end

  # @return [Ability]
  # Creates a type of ability that only allows access to public resources
  def public_ability
    Ability.new(nil)
  end
end
