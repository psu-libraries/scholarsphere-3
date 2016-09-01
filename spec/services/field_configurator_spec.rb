# frozen_string_literal: true
require 'spec_helper'

describe FieldConfigurator do
  describe "#index_fields" do
    subject { described_class.index_fields.keys }
    it {is_expected.to eq([
                            :title,
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
                            :identifier])}
  end

  describe "#show_fields" do
    subject { described_class.show_fields.keys }
    it {is_expected.to eq([:title,
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
                           :depositor
                          ])}
  end

  describe "#facet_fields" do
    subject { described_class.facet_fields.keys }
    it {is_expected.to eq([:resource_type,
                           :creator,
                           :keyword,
                           :subject,
                           :language,
                           :based_near,
                           :publisher,
                           :file_format,
                           :collection,
                           :has_model
                          ])}
  end
end
