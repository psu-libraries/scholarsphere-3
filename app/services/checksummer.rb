# frozen_string_literal: true

require 'digest'

class Checksummer
  # This class returns an array of all the checksums for all the files
  # (and their versions) in a work.
  # @param work [ActiveFedora::Base]
  def initialize(work)
    @work = work
  end

  # @return [Array] an array of checksums from the FixityService
  def fedora_checksums
    checksums = []
    @work.file_sets.each do |file_set|
      file_set.files.each do |file|
        file.versions.all.each do |version|
          checksums << ActiveFedora::FixityService.new(version.uri).expected_message_digest.gsub('urn:sha1:', '')
        end
      end
    end
    checksums
  end

  # @return [Array] an array of checksums generated from the files on disk
  def disk_checksums
    checksums = []
    @work.file_sets.each do |file_set|
      file_set.files.each do |file|
        file.versions.all.each do
          sha1 = Digest::SHA1.new
          open(file_set.original_file.uri,
               http_basic_authentication: [ActiveFedora.fedora_config.credentials['user'],
                                           ActiveFedora.fedora_config.credentials['password']],
               allow_redirections: :all) { |f| f.each_line { |line| sha1.update line } }
          checksums << sha1.hexdigest
        end
      end
    end
    checksums
  end
end
