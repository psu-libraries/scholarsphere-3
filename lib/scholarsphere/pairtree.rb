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
      "/#{identifier[0, 2]}/#{identifier[2, 2]}/#{identifier[4, 2]}/#{identifier[6, 2]}/#{identifier}/#{Time.now.to_f}/"
    end

    def ensure_repository_filestore_exists
      FileUtils::mkdir_p ENV['REPOSITORY_FILESTORE']
    end

    def ensure_object_directory_exists
      FileUtils::mkdir_p ENV['REPOSITORY_FILESTORE'] + new_path
    end

    def create_repository_files(filepath, local_file_name)
      ensure_object_directory_exists
      clean_name = clean_file_name(local_file_name)
      FileUtils::cp filepath, full_path + "/#{clean_name}"
      @bagger.new(full_path: full_path, movable_file: clean_name)
      full_path + "/#{clean_name}"
    end

    def create_repository_files_from_string(stream, local_file_name)
      ensure_object_directory_exists
      @bagger.new(full_path: full_path, string_data: stream, file_name: local_file_name)
      full_path + "/#{local_file_name}"
    end

    def storage_path(url)
      url.gsub(ENV['REPOSITORY_FILESTORE_HOST'], ENV['REPOSITORY_FILESTORE'])
    end

    private

      def storage_dir
        Dir["#{ENV['REPOSITORY_FILESTORE']}/#{@object.id[0, 2]}/#{@object.id[2, 2]}/#{@object.id[4, 2]}/#{@object.id[6, 2]}/#{@object.id}/*"].sort.last || ''
      end

      def clean_file_name(file_name)
        file_name.gsub(/[^0-9A-Za-z.\-]/, '_')
      end
  end
end
