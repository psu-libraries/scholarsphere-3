# frozen_string_literal: true
class FieldConfigurator
  def self.common_fields
    {
      resource_type: FieldConfig.new("Resource Type"),
      creator: FieldConfig.new("Creator"),
      keyword:  FieldConfig.new("Keyword"),
      subject: FieldConfig.new("Subject"),
      language: FieldConfig.new("Language"),
      based_near: FieldConfig.new("Location"),
      publisher: FieldConfig.new("Publisher"),
      file_format: FieldConfig.new("File Format")
    }
  end

  def self.index_fields
    { description: FieldConfig.new("Description") }.merge(
      common_fields).merge(contributor: FieldConfig.new("Contributor"),
                           date_uploaded: FieldConfig.new(label: "Date Uploaded", index_solr_type: :stored_sortable, index_type: :date),
                           date_modified: FieldConfig.new(label: "Date Modified", index_solr_type: :stored_sortable, index_type: :date),
                           date_created: FieldConfig.new("Date Created"),
                           rights: FieldConfig.new("Rights"),
                           identifier: FieldConfig.new("Identifier"))
  end

  def self.show_fields
    index_fields.merge(depositor:  FieldConfig.new("Depositor"))
  end

  def self.facet_fields
    common_fields.merge(collection: FieldConfig.new(label: "Collection", helper_method: :collection_helper_method),
                        file_format: FieldConfig.new(label: "File Format"),
                        has_model: FieldConfig.new(label: "Object Type", helper_method: :titleize, solr_type: :symbol)
                       )
  end

  def self.search_fields
    show_fields.merge(title: FieldConfig.new("Title"))
  end
end
