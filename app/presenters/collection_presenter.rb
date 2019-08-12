# frozen_string_literal: true

class CollectionPresenter < Sufia::CollectionPresenter
  include ZipDownloadBehavior

  delegate :subtitle, :bytes, to: :solr_document

  def self.terms
    [:creator, :keyword, :rights, :resource_type, :contributor, :publisher, :date_created, :date_uploaded,
     :date_modified, :subject, :language, :identifier, :based_near, :related_url, :size, :total_items]
  end

  def permission_badge_class
    PublicPermissionBadge
  end

  def creator_facet_path(index)
    Rails.application.routes.url_helpers.search_catalog_path(:"f[#{:creator_name_sim}][]" => cleaned_creators[index])
  end

  def cleaned_creators
    @cleaned_creators ||= FacetValueCleaningService.call(creator, FieldConfig.new(facet_cleaners: [:creator]), solr_document)
  end

  def zip_available?
    return false if total_items.zero?

    zip_download_path.present?
  end
end
