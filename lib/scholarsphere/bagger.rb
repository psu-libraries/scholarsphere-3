# frozen_string_literal: true

module Scholarsphere
  class Bagger
    def initialize(full_path: base_path, working_file: nil, movable_file: nil, string_data: nil, file_name: nil)
      @bag = BagIt::Bag.new(full_path)
      if movable_file.present?
        filename = movable_file
        filename = File.join(full_path, filename) if File.basename(filename) == filename
        FileUtils.mv(filename, File.join(full_path, '/data'))
        FileUtils.chmod 'g+r,a+r', File.join(full_path, '/data', File.basename(filename))
      elsif working_file.present?
        @bag.add_file(File.basename(working_file)) do |io|
          IO.foreach(working_file).each { |line| io.write line }
        end
      else
        string_data ||= ''
        @bag.add_file(file_name) do |io|
          io.write string_data.force_encoding('utf-8')
        end
      end
      @bag.manifest!(algo: 'sha256')
    end
  end
end
