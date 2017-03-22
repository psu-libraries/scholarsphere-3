# frozen_string_literal: true
module Export
  class VersionConverter < Sufia::Export::VersionConverter
    # Create an instance of a GenericFile version containing all the metadata for json export
    #  Includes the creator, which is not in the sufia data
    #
    # @param [String] uri location of version to be converted in fedora (also id of version)
    # @param [ActiveFedora::VersionsGraph] version_graph the graph of versions associated with one GenericFile (gf.content.versions)
    def initialize(uri, version_graph)
      super
      @created_by = version_committer
      version_date
    end

    private

      def version_committer
        vc = VersionCommitter.where(version_id: uri)
        vc.empty? ? nil : vc.first.committer_login
      end

      # grab the version date from the version committer information since we lost the actual version date when we migrated
      def version_date
        vc = VersionCommitter.where(version_id: uri)
        @created = vc.first.created_at unless vc.empty?
      end
  end
end
