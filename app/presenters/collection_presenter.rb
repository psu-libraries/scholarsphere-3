# frozen_string_literal: true

class CollectionPresenter < Sufia::CollectionPresenter
  delegate :subtitle, to: :solr_document

  # TODO: Move to Sufia?
  def self.terms
    super + [:date_modified, :date_uploaded]
  end

  def permission_badge_class
    PublicPermissionBadge
  end
end
