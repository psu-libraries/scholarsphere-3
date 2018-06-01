# frozen_string_literal: true

require 'rails_helper'

describe FieldConfigurator do
  describe '::index_fields' do
    subject { described_class.index_fields.keys }

    it { is_expected.to contain_exactly(:resource_type,
                                       :creator_name,
                                       :keyword,
                                       :subject,
                                       :language,
                                       :based_near,
                                       :publisher,
                                       :has_model,
                                       :date_uploaded) }
  end

  describe '::show_fields' do
    subject { described_class.show_fields.keys }

    it { is_expected.to contain_exactly(:description,
                                       :resource_type,
                                       :creator_name,
                                       :keyword,
                                       :subject,
                                       :language,
                                       :based_near,
                                       :publisher,
                                       :contributor,
                                       :date_uploaded,
                                       :date_modified,
                                       :date_created,
                                       :rights,
                                       :identifier,
                                       :depositor,
                                       :subtitle) }
  end

  describe '::facet_fields' do
    subject { described_class.facet_fields.keys }

    it { is_expected.to contain_exactly(:resource_type,
                                       :creator_name,
                                       :keyword,
                                       :subject,
                                       :language,
                                       :based_near,
                                       :publisher,
                                       :file_format,
                                       :collection,
                                       :has_model) }

    describe 'creator facet' do
      subject { described_class.facet_fields.fetch(:creator_name) }

      its(:opts) { is_expected.to include(facet_cleaners: [:creator]) }
    end

    describe 'publisher facet' do
      subject { described_class.facet_fields.fetch(:publisher) }

      its(:opts) { is_expected.to include(facet_cleaners: [:titleize]) }
    end

    describe 'keyword facet' do
      subject { described_class.facet_fields.fetch(:keyword) }

      its(:opts) { is_expected.to include(facet_cleaners: [:downcase]) }
    end
  end

  describe '::search_fields' do
    subject { described_class.search_fields.keys }

    it { is_expected.to contain_exactly(:title,
                                       :description,
                                       :resource_type,
                                       :creator_name,
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
                                       :depositor,
                                       :subtitle) }
  end
end
