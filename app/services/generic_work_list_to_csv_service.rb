# frozen_string_literal: true

class GenericWorkListToCSVService
  attr_reader :works, :terms

  def initialize(works)
    @works = works
  end

  def csv
    # using all terms here to create a work and fileset heading
    csv_data = Sufia::FileSetCSVService.new(files[0], all_terms).csv_header.titleize

    files.each do |fs|
      # get the csv data for the fileset only
      file_csv_data = Sufia::FileSetCSVService.new(fs, file_set_terms).csv

      # since the FileSetCSVService does not really care what type of object it works on
      # we are going to use it to produce work level data for each file set parent work
      work_csv_data = Sufia::FileSetCSVService.new(fs.parent, work_terms).csv.delete("\n")

      # add the entire line to the csv file
      csv_data.concat("#{work_csv_data},#{file_csv_data}")
    end
    csv_data
  end

  private

    def all_terms
      return @all_terms if @all_terms.present?
      mapped_work_terms = work_terms.map { |term| "work_#{term}" }
      mapped_file_set_terms = file_set_terms.map { |term| "file_set_#{term}" }
      @all_terms = mapped_work_terms + mapped_file_set_terms
    end

    def file_set_terms
      @file_set_terms ||= %i(url time_uploaded id title depositor creator visibility file_format)
    end

    def work_terms
      @work_terms ||= %i(url id title resource_type rights)
    end

    def files
      @files ||= works.map(&:file_sets).flatten
    end
end
