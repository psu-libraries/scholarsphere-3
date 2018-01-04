# frozen_string_literal: true

class CollectionPresenter < Sufia::CollectionPresenter
  delegate :subtitle, to: :solr_document

  def self.terms
    [:creator, :keyword, :size, :total_items, :resource_type, :contributor,
     :rights, :publisher, :date_created, :subject, :language, :identifier,
     :based_near, :related_url, :date_modified, :date_uploaded]
  end

  def permission_badge_class
    PublicPermissionBadge
  end
end
