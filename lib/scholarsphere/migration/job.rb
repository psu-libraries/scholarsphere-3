# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Job < ApplicationJob
      queue_as :migration

      # @param [Scholarsphere::Migration::Resource] resource
      def perform(resource)
        resource.migrate
      end
    end
  end
end
