# frozen_string_literal: true

class PublicFilteredList
  attr_reader :generic_files, :filters

  def initialize(generic_files)
    @generic_files = generic_files
    @filters = []
  end

  def filter
    @public_members ||= generic_files.select(&:public?)
  end
end
