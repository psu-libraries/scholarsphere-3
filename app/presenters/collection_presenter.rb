# frozen_string_literal: true

class CollectionPresenter < Sufia::CollectionPresenter
  delegate :subtitle, to: :solr_document

  def self.terms
    [:creator, :keyword, :rights, :resource_type, :contributor, :publisher, :date_created, :date_uploaded,
     :date_modified, :subject, :language, :identifier, :based_near, :related_url, :size, :total_items]
  end

  def permission_badge_class
    PublicPermissionBadge
  end
end
