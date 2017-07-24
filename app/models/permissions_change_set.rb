# frozen_string_literal: true
# Create a hash representation of a file's permissions before and after a change:
#   > file = GenericFile.new
#   > before = file.permissions.map(&:to_hash)
#   > [make changes to file permissions]
#   > after = file.permissions
#
# Create a change set to represent the changes:
#   >  set = PermissionsChangeSet.new(before, after)
#   >  set.removed
#   => [ { name: "xyz123", type: "group", access: "read" }, ... ]
#   >  set.added
#   => [ { name: "abd123", type: "person", access: "edit" }, ... ]
#
class PermissionsChangeSet
  attr_reader :before, :after

  # @param [Hash] before state of a file's permissions
  # @param [Hash] after state of a file's permissions
  def initialize(before, after)
    @before = before
    @after = after
  end

  def added
    delta.fetch(:added, [])
  end

  def removed
    delta.fetch(:removed, [])
  end

  def privatized?
    return false if unchanged?
    removed.include?(public_group_read)
  end

  def publicized?
    return false if unchanged?
    added.include?(public_group_read)
  end

  def unchanged?
    added.empty? && removed.empty?
  end

  private

    def delta
      @delta ||= { added: (after.to_a - before.to_a), removed: (before.to_a - after.to_a) }
    end

    def public_group_read
      { name: 'public', type: 'group', access: 'read' }
    end
end
