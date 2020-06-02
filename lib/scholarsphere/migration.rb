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
    require 'job'
    require 'permissions'
    require 'resource'
    require 'work'
    require 'work_type_mapper'
  end
end
