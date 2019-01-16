# frozen_string_literal: true

# Stand-in class for rendering BatchEditForm, similar to BatchCreateItem. It should never be persisted, and
# only holds values assigned by the form which are subsequently applied to each object in the batch
# during BatchEditsController#update.
class BatchEditItem < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::BasicMetadata
  include Sufia::WorkBehavior
  include AdditionalMetadata
  include HasCreators

  self.human_readable_type = 'Batch Edit Item'

  attr_reader :batch

  def initialize(args)
    @batch = args.delete(:batch).map { |id| GenericWork.find(id) }
    super
  end

  # Return a value for visibility only if all the items in the batch have the same value.
  # This is used when rendering the form so that a value is only shown if they're all the same.
  def visibility
    range = batch.map(&:visibility).uniq
    return nil if range.count > 1

    range.first
  end

  # @return [Array<Alias>] with duplicates removed.
  # @note Creators are ActiveTriples::Relation which must be cast to arrays before they can be flattened.
  def creators
    creators = batch.map(&:creators).map(&:to_a).flatten
    creators.uniq(&:id)
  end
end
