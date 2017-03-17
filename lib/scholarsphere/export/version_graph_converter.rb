# frozen_string_literal: true
module Export
  class VersionGraphConverter < Sufia::Export::VersionGraphConverter
    private

      def parse(graph)
        # changing to use all so we do not output the auto created versions
        graph.all.map(&:uri).each do |uri|
          versions << VersionConverter.new(uri, graph)
        end
      end
  end
end
