class ResourceFilteredList

  attr_reader :generic_files, :resource_types

  def initialize(generic_files, resource_types = ["Dataset", "Posters", "Thesis", "Dissertation", "Report"] )
    @generic_files = generic_files
    @resource_types = resource_types
  end

  def filter
    @filtered ||= generic_files.reject{|gf| !((gf.resource_type & resource_types).count >0)}
  end

end