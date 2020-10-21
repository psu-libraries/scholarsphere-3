# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Error < StandardError; end

    require 'collection'
    require 'creator'
    require 'data_report'
    require 'date_validator'
    require 'depositor'
    require 'depositors_report'
    require 'export_service'
    require 'file_set'
    require 'identifier'
    require 'job'
    require 'permissions'
    require 'resource'
    require 'rights'
    require 'statistics'
    require 'work'
    require 'work_type_mapper'

    class << self
      def log
        @log ||= Logger.new('log/migration.log')
      end
    end
  end
end
