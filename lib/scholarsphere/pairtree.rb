# frozen_string_literal: true

module Scholarsphere
  class Pairtree
    attr_reader :object
    def initialize(object, bagger)
      @object = object
      @bagger = bagger
      ensure_repository_filestore_exists
    end

    # Given an ActiveFedora object, generate a pair tree
    # path for it based on its id
    # @param [ActiveFedora::Base] object
    def full_path
      if File.exists?(storage_dir + '/data')
        storage_dir + '/data'
      else
        storage_dir
      end
    end

    def path
      full_path.gsub(ENV['REPOSITORY_FILESTORE'], '')
    end

    def http_path(filepath)
      ENV['REPOSITORY_FILESTORE_HOST'] + path + '/' + File.basename(filepath)
    end

    def new_path
      identifier = @object.id
      "/#{identifier[0, 2]}/#{identifier[2, 2]}/#{identifier[4, 2]}/#{identifier[6, 2]}/#{identifier}/#{Time.now.to_i}/"
    end

    def ensure_repository_filestore_exists
      FileUtils::mkdir_p ENV['REPOSITORY_FILESTORE']
    end

    def ensure_object_directory_exists
      FileUtils::mkdir_p ENV['REPOSITORY_FILESTORE'] + new_path
    end

    def create_repository_files(filepath)
      ensure_object_directory_exists
      FileUtils::cp filepath, full_path
      @bagger.new(full_path: full_path, working_file: File.basename(filepath))
      remove_file_outside_bag(filepath)
    end

    private

      def storage_dir
        Dir["#{ENV['REPOSITORY_FILESTORE']}/#{@object.id[0, 2]}/#{@object.id[2, 2]}/#{@object.id[4, 2]}/#{@object.id[6, 2]}/#{@object.id}/*"].sort.last
      end

      def remove_file_outside_bag(filepath)
        File.unlink(full_path.gsub('/data', '') + '/' + File.basename(filepath))
      end
  end
end
