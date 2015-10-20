class PublicFilteredList

  attr_reader :generic_files, :filters

  def initialize(generic_files)
    @generic_files = generic_files
    @filters = []
  end

  def filter
    @public_members ||= generic_files.reject{|gf| !gf.public?}
  end

end