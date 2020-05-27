# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Error < StandardError; end

    require 'data_report'
    require 'depositors_report'
    require 'work'
    require 'collection'
    require 'creator'
    require 'depositor'
    require 'permissions'
    require 'work_type_mapper'
    require 'export_service'
    require 'resource'
    require 'job'
  end
end
