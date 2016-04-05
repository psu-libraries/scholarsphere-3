# frozen_string_literal: true
class GenericWorkListToCSVService
  attr_reader :works, :terms

  def initialize(works)
    @works = works
  end

  def csv
    csv_data = Sufia::FileSetCSVService.new(files[0], terms).csv_header.titleize
    files.each do |fs|
      csv_data.concat(Sufia::FileSetCSVService.new(fs, terms).csv)
    end
    csv_data
  end

  private

    def terms
      @terms ||= [:url, :time_uploaded].concat(Sufia::FileSetCSVService.new(nil).terms)
    end

    def files
      @files ||= works.map(&:file_sets).flatten
    end
end
