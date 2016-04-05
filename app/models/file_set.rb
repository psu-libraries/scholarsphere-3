# frozen_string_literal: true
class FileSet < ActiveFedora::Base
  extend Deprecation
  include ::CurationConcerns::FileSetBehavior
  include Sufia::FileSetBehavior

  def file_format
    Deprecation.warn(self, "Calling FileSet.file_format is deprecated. Use the value in its solr_document instead")
    return nil if mime_type.blank? && format_label.blank?
    return mime_type.split('/')[1] + " (" + format_label.join(", ") + ")" unless mime_type.blank? || format_label.blank?
    return mime_type.split('/')[1] unless mime_type.blank?
    format_label
  end

  # TODO: Move to SolrDocument
  def url
    "#{current_host}#{Rails.application.routes.url_helpers.curation_concerns_file_set_path(self)}"
  end

  # TODO: Move to SolrDocument
  def time_uploaded
    date_uploaded.blank? ? "" : date_uploaded.strftime("%Y-%m-%d %H:%M:%S")
  end

  private

    def current_host
      Rails.application.get_vhost_by_host[1].chomp("/")
    end
end
