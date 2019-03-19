# frozen_string_literal: true

# returns the location of the FileSet original file on disk
#
class FileSetDiskLocation
  attr_reader :path

  def initialize(file_set)
    pcdm_file = file_set.association(:original_file).find_target
    disk_file_url = ActiveFedora.fedora.connection.head(pcdm_file.uri).response.headers['content-type'].split('"')[1]
    @path = Scholarsphere::Pairtree.new(file_set, nil).storage_path(disk_file_url)
  end
end
