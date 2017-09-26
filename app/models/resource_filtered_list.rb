# frozen_string_literal: true

class ResourceFilteredList
  attr_reader :generic_files, :resource_types

  def initialize(generic_files, resource_types = ['Dataset', 'Poster', 'Thesis', 'Dissertation'])
    @generic_files = generic_files
    @resource_types = resource_types
  end

  def filter
    @filtered ||= generic_files.select { |gf| (gf.resource_type.to_ary & resource_types).count.positive? }
  end
end
