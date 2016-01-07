class ShareNotifyFilteredList

  attr_reader :generic_files, :filters

  def initialize(generic_files)
    @generic_files = generic_files
    @filters = []
  end

  def filter
    @unshared_files ||= generic_files.reject{|gf| gf.share_notified?}
  end

end
