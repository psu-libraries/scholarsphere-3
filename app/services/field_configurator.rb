# frozen_string_literal: true

class FieldConfigurator
  # Defines what fields are shown on the search index view for each item
  def self.index_fields
    common_fields.merge(date_uploaded: FieldConfig.new(label: 'Date Uploaded',
                                                       index_solr_type: :stored_sortable,
                                                       index_type: :date))
  end

  # Defines what fields are shown on the work show page
  def self.show_fields
    index_fields
      .except(:has_model)
      .merge(depositor:  FieldConfig.new('Depositor'),
             contributor: FieldConfig.new('Contributor'),
             date_modified: FieldConfig.new(label: 'Date Modified',
                                            index_solr_type: :stored_sortable,
                                            index_type: :date),
             date_created: FieldConfig.new('Date Created'),
             rights: FieldConfig.new('Rights'),
             identifier: FieldConfig.new('Identifier'),
             description: FieldConfig.new('Description'),
             subtitle: FieldConfig.new('Subtitle'))
  end

  # Defines what fields are shown in the facets on the search index view
  def self.facet_fields
    common_fields.merge(collection: FieldConfig.new(label: 'Collection', helper_method: :collection_helper_method),
                        file_format: FieldConfig.new('File Format'))
  end

  # Defines what fields are available to the user in the universal search
  def self.search_fields
    show_fields.merge(title: FieldConfig.new('Title'),
                      file_format: FieldConfig.new('File Format'))
  end

  # Common fields between all lists
  def self.common_fields
    {
      resource_type: FieldConfig.new('Resource Type'),
      creator_name: FieldConfig.new(label: 'Creator', facet_cleaners: [:creator]),
      keyword:  FieldConfig.new(label: 'Keyword', facet_cleaners: [:downcase]),
      subject: FieldConfig.new('Subject'),
      language: FieldConfig.new('Language'),
      based_near: FieldConfig.new('Location'),
      publisher: FieldConfig.new(label: 'Publisher', facet_cleaners: [:titleize]),
      has_model: FieldConfig.new(label: 'Object Type',
                                 helper_method: :titleize,
                                 index_solr_type: :symbol,
                                 solr_type: :symbol)
    }
  end
end
