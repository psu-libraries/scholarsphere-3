module ActiveFedora
  class UnsavedDigitalObject
    def assign_pid
      @pid ||= Sufia::IdService.mint
    end
  end
end
