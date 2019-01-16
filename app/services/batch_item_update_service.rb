# frozen_string_literal: true

# Updates terms, permissions, and visibility for a given object in a batch.
class BatchItemUpdateService
  attr_reader :curation_concern, :params, :current_user

  # @param [String] id
  # @param [ActionController::Parameters] params from the BatchEditsController
  # @param [User] current_user from the BatchEditsController
  def initialize(id, params, current_user)
    @curation_concern = ActiveFedora::Base.find(id)
    @params = params
    @current_user = current_user
  end

  def update
    initial_visibility = curation_concern.visibility
    actor = CurationConcerns::CurationConcern.actor(curation_concern, current_user)
    actor.update(actor_params)
    save_embargoes_and_leases
    VisibilityCopyJob.perform_later(curation_concern) if visibility_changed?(initial_visibility)
    InheritPermissionsJob.perform_later(curation_concern) if permissions_changed?
  end

  private

    # Adjusts the permissions parameters so that any permissions with ids are changed to match the
    # permissions on the curation_concern.
    def actor_params
      return params if !permissions_changed? || !has_incorrect_ids?

      new_permissions = updated_permissions_with_ids
      params[:permissions_attributes] = new_permissions + permissions_without_ids
      params
    end

    def visibility_changed?(initial_visibility)
      selected_visibility = params.fetch(:visibility, nil)
      return false unless selected_visibility

      initial_visibility != selected_visibility
    end

    def save_embargoes_and_leases
      curation_concern.embargo&.save
      curation_concern.lease&.save
    end

    # @return [Boolean]
    # Determines if the permissions in the parameters are the same ones in the curation_concern
    def has_incorrect_ids?
      common_permissions = curation_concern.permissions.map(&:id) & permissions_with_ids.map { |p| p[:id] }
      common_permissions.empty?
    end

    def permissions_changed?
      params.key?(:permissions_attributes)
    end

    def permissions_with_ids
      separated_permissions.first
    end

    def permissions_without_ids
      separated_permissions.last
    end

    def separated_permissions
      @separated_permissions ||= params.fetch(:permissions_attributes, {}).values.partition { |h| h.key?('id') }
    end

    # @return[Array<Hash>]
    # Permissions with updated ids corresponding to the ids of permissions on the present curation_concern
    def updated_permissions_with_ids
      Rails.logger.info("Updating permissions ids for #{curation_concern.title}")
      permissions_with_ids.each do |permission|
        new_id = updated_id(permission)
        permission[:id] = new_id
      end
    end

    def updated_id(permission)
      curation_concern.permissions.to_a.select do |p|
        p.to_hash[:name] == permission[:name] && p.to_hash[:type] == permission[:type] && p.to_hash[:access] == permission[:access]
      end.map(&:id).first
    end
end
