class GenericFileListToCSVService

  attr_reader :generic_files, :terms

  def initialize( generic_files)
    @generic_files = generic_files
  end

  def csv
    csv_data = Sufia::GenericFileCSVService.new(generic_files[0],terms).csv_header
    generic_files.each do |gf|
      csv_data.concat(Sufia::GenericFileCSVService.new(gf,terms).csv)
    end
    csv_data
  end

  def terms
    @terms ||= [:url].concat(Sufia::GenericFileCSVService.new(nil).terms)
  end
end
