# frozen_string_literal: true
require 'rails_helper'

describe FieldConfigurator do
  describe "::index_fields" do
    subject { described_class.index_fields.keys }
    it {is_expected.to contain_exactly(:description,
                                       :resource_type,
                                       :creator,
                                       :keyword,
                                       :subject,
                                       :language,
                                       :based_near,
                                       :publisher,
                                       :file_format,
                                       :contributor,
                                       :date_uploaded,
                                       :date_modified,
                                       :date_created,
                                       :rights,
                                       :identifier) }
  end

  describe "::show_fields" do
    subject { described_class.show_fields.keys }
    it {is_expected.to contain_exactly(:description,
                                       :resource_type,
                                       :creator,
                                       :keyword,
                                       :subject,
                                       :language,
                                       :based_near,
                                       :publisher,
                                       :file_format,
                                       :contributor,
                                       :date_uploaded,
                                       :date_modified,
                                       :date_created,
                                       :rights,
                                       :identifier,
                                       :depositor) }
  end

  describe "::facet_fields" do
    subject { described_class.facet_fields.keys }
    it {is_expected.to contain_exactly(:resource_type,
                                       :creator,
                                       :keyword,
                                       :subject,
                                       :language,
                                       :based_near,
                                       :publisher,
                                       :file_format,
                                       :collection,
                                       :has_model) }
  end

  describe "::search_fields" do
    subject { described_class.search_fields.keys }
    it {is_expected.to contain_exactly(:title,
                                       :description,
                                       :resource_type,
                                       :creator,
                                       :keyword,
                                       :subject,
                                       :language,
                                       :based_near,
                                       :publisher,
                                       :file_format,
                                       :contributor,
                                       :date_uploaded,
                                       :date_modified,
                                       :date_created,
                                       :rights,
                                       :identifier,
                                       :depositor) }
  end
end
