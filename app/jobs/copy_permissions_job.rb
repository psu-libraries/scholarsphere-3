# frozen_string_literal: true

# Combines VisibilityCopyJob from CurationConcerns and InheritPermissionsJob from Sufia into one job.
class CopyPermissionsJob < ApplicationJob
  def perform(work)
    work.file_sets.each do |file|
      perform_copy(file, work: work)
    end
  end

  private

    def perform_copy(file, work:)
      copy_visibility_lease_and_embargo(file, work: work)

      copy_permissions(file, work: work)

      # Copy depositor from the work to the fileset
      file.depositor = work.depositor unless work.depositor == file.depositor

      file.save!
    end

    def copy_visibility_lease_and_embargo(file, work:)
      # Copy visibility and any leases or embargoes from the work to the file.
      # Visibility must come first because it can clear an embargo/lease.
      file.visibility = work.visibility
      if work.lease
        file.build_lease unless file.lease
        file.lease.attributes = work.lease.attributes.except('id')
      elsif work.embargo
        file.build_embargo unless file.embargo
        file.embargo.attributes = work.embargo.attributes.except('id')
      end
    end

    def copy_permissions(file, work:)
      attribute_map = work.permissions.map(&:to_hash)

      # Mark any attributes deleted if they are not present in the work
      file.permissions.map(&:to_hash).each do |perm|
        unless attribute_map.include?(perm)
          perm[:_destroy] = true
          attribute_map << perm
        end
      end
      # Apply the new and deleted attributes to the file
      file.permissions_attributes = attribute_map
    end
end
