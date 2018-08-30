# frozen_string_literal: true

module Scholarsphere
  class Bagger
    def initialize(full_path: base_path, working_file: file)
      current_directory = Dir.pwd
      Dir.chdir(full_path)
      @bag = BagIt::Bag.new(full_path)
      @bag.add_file(working_file) do |io|
        IO.foreach(working_file).each { |line| io.puts line }
      end
      @bag.manifest!(algo: 'sha256')
      Dir.chdir(current_directory)
    end
  end
end
