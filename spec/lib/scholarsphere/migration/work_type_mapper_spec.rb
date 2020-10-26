# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::WorkTypeMapper do
  describe '#work_type' do
    context 'when there are no resource types' do
      its(:work_type) { is_expected.to be_nil }
    end

    context 'when there is one resource type' do
      it 'maps the SS3 value to the SS4 value' do
        {
          'Audio' => 'audio',
          'Book' => 'book',
          'Capstone Project' => 'capstone_project',
          'Conference Proceeding' => 'conference_proceeding',
          'Dataset' => 'dataset',
          'Dissertation' => 'dissertation',
          'Image' => 'image',
          'Journal' => 'journal',
          'Map or Cartographic Material' => 'map_or_cartographic_material',
          'Masters Culminating Experience' => 'masters_culminating_experience',
          'Masters Thesis' => 'masters_thesis',
          'Part of Book' => 'part_of_book',
          'Poster' => 'poster',
          'Presentation' => 'presentation',
          'Project' => 'project',
          'Report' => 'report',
          'Research Paper' => 'research_paper',
          'Software or Program Code' => 'software_or_program_code',
          'Video' => 'video',
          'Other' => 'other'
        }.each do |ss3_value, ss4_value|
          expect(described_class.new(resource_types: [ss3_value]).work_type).to eq(ss4_value)
        end
      end
    end
  end
end
